PRAGMA foreign_keys = ON;

DROP TABLE replies;
DROP TABLE question_follows;
DROP TABLE question_likes;
DROP TABLE questions;
DROP TABLE users;

CREATE TABLE users(
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL, 
  lname TEXT NOT NULL
  );

CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  qbody TEXT NOT NULL,
  qauthor_id INTEGER NOT NULL,

  FOREIGN KEY (qauthor_id) REFERENCES users(id)
);

CREATE TABLE question_follows(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  subject_q INTEGER NOT NULL,
  parent_id INTEGER,
  rauthor_id INTEGER NOT NULL,
  rbody TEXT NOT NULL,

  FOREIGN KEY (subject_q) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (rauthor_id) REFERENCES users(id)
);

CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
  liked_user INTEGER NOT NULL,
  liked_q INTEGER NOT NULL,

  FOREIGN KEY (liked_user) REFERENCES users(id),
  FOREIGN KEY (liked_q) REFERENCES questions(id)
);



INSERT INTO
  users (fname, lname)
VALUES
  ('Albert', 'Cheng'),
  ('Think', 'Hsu'),
  ('Sake', 'Doge');

INSERT INTO
  questions(title, qbody, qauthor_id)
VALUES
  ('How to enroll in AA?', 'What are the steps I need to do to enroll in AA?', 1),
  ('Woof woof?', 'Awuuuu, ruu ruu ruuuu?', 3),
  ('Similar program like AA?', 'Are there any similar program like AA but for other fields?', 2);

INSERT INTO
  question_likes(liked_user, liked_q)
VALUES
  (1, 2),
  (2, 2),
  (3, 2),
  (1, 3),
  (3, 3);

INSERT INTO
  question_follows(user_id, question_id)
VALUES
  (1, 1),
  (1, 3),
  (2, 1),
  (2, 3),
  (3, 1),
  (3, 2),
  (3, 3);

INSERT INTO
  replies(subject_q, parent_id, rauthor_id, rbody)
VALUES
  (2, NULL, 1, 'I don''t understand you!'),
  (2, 1, 2, 'So cute!'),
  (2, 2, 3, 'Ruuuuuuuoo!'),
  (3, NULL, 1, 'I want to know too!'),
  (3, NULL, 2, 'Anyone has any idea?'),
  (3, 5, 3, 'Ruu?');