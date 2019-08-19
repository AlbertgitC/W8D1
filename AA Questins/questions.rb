require 'sqlite3'
require 'singleton'

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

    User.new(user.first) 
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
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

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @qbody = options['qbody']
    @qauthor_id = options['qauthor_id']
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

  def initialize(options)
    @id = options['id']
    @subject_q = options['subject_q']
    @parent_id = options['parent_id']
    @rauthor_id = options['rauthor_id']
    @rbody = options['rbody']
  end
end