require 'sqlite3'
require 'singleton'
require 'byebug'

class QuestionsDB < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end


class User
  attr_accessor :id, :fname, :lname

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_id(id)
    user = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?;
    SQL
    return nil unless user.length > 0
    User.new(user.first) 
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDB.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND
        lname = ?;
    SQL
    return nil unless user.length > 0

    users = []
    user.each do |u|
      users << User.new(u)
    end
    users
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end
end


class Question
  attr_accessor :id, :title, :qbody, :qauthor_id

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_id(id)
    question = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?;
    SQL
    return nil unless question.length > 0
    Question.new(question.first) 
  end

  def self.find_by_author_id(author_id)
    question = QuestionsDB.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        qauthor_id = ?;
    SQL
    return nil unless question.length > 0

    questions = []
    question.each do |q|
      questions << Question.new(q)
    end
    questions 
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @qbody = options['qbody']
    @qauthor_id = options['qauthor_id']
  end

  def author
    User.find_by_id(self.qauthor_id)
  end

  def replies
    Reply.find_by_question_id(self.id)
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end
end


class QuestionLikes
  attr_accessor :id, :liked_user, :liked_q

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLikes.new(datum) }
  end

  def self.find_by_id(id)
    questionlikes = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?;
    SQL
    return nil unless questionlikes.length > 0
    QuestionLikes.new(questionlikes.first) 
  end

  def self.likers_for_question_id(question_id)
    liker = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      JOIN
        question_likes ON users.id = question_likes.liked_user
      WHERE
        question_likes.liked_q = ?;
    SQL
    return nil unless liker.length > 0

    likers = []
    liker.each { |user| likers << User.new(user) }
    likers
  end

  def self.num_likes_for_question_id(question_id)
    num_likes = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(liked_user)
      FROM
        question_likes
      WHERE
        liked_q = ?;
    SQL
    return nil if Question.find_by_id(question_id).nil? || num_likes.empty?

    num_likes.first['COUNT(liked_user)']
  end

  def self.liked_questions_for_user_id(user_id)
    liked_q = QuestionsDB.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_likes ON questions.id = question_likes.liked_q
      WHERE
        liked_user = ?;
    SQL
    return nil if liked_q.empty?

    liked_qs = []
    liked_q.each { |q| liked_qs << Question.new(q) }
    liked_qs
  end

  def initialize(options)
    @id = options['id']
    @liked_user = options['liked_user']
    @liked_q = options['liked_q']
  end
end


class QuestionFollow
  attr_accessor :id, :user_id, :question_id

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.find_by_id(id)
    question_follow = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?;
    SQL
    return nil unless question_follow.length > 0
    QuestionFollow.new(question_follow.first) 
  end

  def self.followers_for_question_id(question_id)
    follower = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      JOIN
        question_follows ON users.id = question_follows.user_id
      WHERE
        question_id = ?;
    SQL
    return nil unless follower.length > 0
    
    followers = []
    follower.each { |f| followers << User.new(f) }
    followers
  end

  def self.followed_questions_for_user_id(user_id)
    q_followed = QuestionsDB.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_follows ON questions.id = question_follows.question_id
      WHERE
        user_id = ?;
    SQL
    return nil unless q_followed.length > 0
    
    questions = []
    q_followed.each { |q| questions << Question.new(q) }
    questions
  end

  def self.most_followed_questions(n)
    most_followed = QuestionsDB.instance.execute(<<-SQL)
      SELECT
        COUNT(user_id), questions.*
      FROM
        question_follows
      JOIN
        questions ON questions.id = question_follows.question_id 
      GROUP BY
        question_id
      ORDER BY
        COUNT(user_id) DESC;
    SQL
    return nil if most_followed.length <= 0 || most_followed.length < n
    
    Question.new(most_followed[n - 1])
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end


class Reply
  attr_accessor :id, :subject_q, :parent_id, :rauthor_id, :rbody

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_id(id)
    reply = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?;
    SQL
    return nil unless reply.length > 0
    Reply.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    reply = QuestionsDB.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        rauthor_id = ?;
    SQL
    return nil unless reply.length > 0

    replies = []
    reply.each do |r|
      replies << Reply.new(r)
    end
    replies 
  end

  def self.find_by_question_id(question_id)
    reply = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        subject_q = ?;
    SQL
    return nil unless reply.length > 0

    replies = []
    reply.each do |r|
      replies << Reply.new(r)
    end
    replies 
  end

  def initialize(options)
    @id = options['id']
    @subject_q = options['subject_q']
    @parent_id = options['parent_id']
    @rauthor_id = options['rauthor_id']
    @rbody = options['rbody']
  end

  def author
    User.find_by_id(self.rauthor_id)
  end

  def question
    Question.find_by_id(self.subject_q)
  end

  def parent_reply
    Reply.find_by_id(self.parent_id)
  end

  def child_replies
    reply = QuestionsDB.instance.execute(<<-SQL, self.id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?;
    SQL
    return nil unless reply.length > 0

    replies = []
    reply.each do |r|
      replies << Reply.new(r)
    end
    replies 
  end
end