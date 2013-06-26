-- DATABASE: woodegg
DROP SCHEMA IF EXISTS woodegg CASCADE;

BEGIN;

CREATE SCHEMA woodegg;
SET search_path = woodegg;

CREATE TABLE researchers (
	id serial primary key,
	person_id integer not null UNIQUE,
	bio text
);
CREATE TABLE writers (
	id serial primary key,
	person_id integer not null UNIQUE,
	bio text
);
CREATE TABLE customers (
	id serial primary key,
	person_id integer not null UNIQUE
);
CREATE TABLE editors (
	id serial primary key,
	person_id integer not null UNIQUE
);


CREATE TABLE topics (
	id serial primary key,
	topic varchar(32)
);

CREATE TABLE subtopics (
	id serial primary key,
	topic_id integer not null REFERENCES topics(id),
	subtopic varchar(64)
);

-- {COUNTRY} instead of country name.
-- to normalize, to see same question across many countries
CREATE TABLE template_questions (
	id serial primary key,
	subtopic_id integer not null REFERENCES subtopics(id),
	question text
);
CREATE INDEX tqti ON template_questions(subtopic_id);

CREATE TABLE questions (
	id serial primary key,
	template_question_id integer not null REFERENCES template_questions(id),
	country char(2) not null,
	question text
);
CREATE INDEX qtqi ON questions(template_question_id);

CREATE TABLE answers (
	id serial primary key,
	question_id integer not null REFERENCES questions(id),
	researcher_id integer not null REFERENCES researchers(id),
	started_at timestamp(0) with time zone,
	finished_at timestamp(0) with time zone,
	payable boolean,
	answer text,
	sources text
);
CREATE INDEX anqi ON answers(question_id);
CREATE INDEX anri ON answers(researcher_id);
CREATE INDEX ansa ON answers(started_at);
CREATE INDEX anfa ON answers(finished_at);
CREATE INDEX anpy ON answers(payable);

CREATE TABLE books (
	id serial primary key,
	country char(2) not null,
	code char(6) not null UNIQUE,
	title text,
	isbn text,
	asin char(10),
	leanpub varchar(30),
	salescopy text
);

CREATE TABLE books_writers (
	book_id integer not null REFERENCES books(id),
	writer_id integer not null REFERENCES writers(id),
	PRIMARY KEY (book_id, writer_id)
);

CREATE TABLE books_researchers (
	book_id integer not null references books(id),
	researcher_id integer not null references researchers(id),
	primary key (book_id, researcher_id)
);

CREATE TABLE books_customers (
	book_id integer not null references books(id),
	customer_id integer not null references customers(id),
	primary key (book_id, customer_id)
);

CREATE TABLE books_editors (
	book_id integer not null REFERENCES books(id),
	editor_id integer not null REFERENCES editors(id),
	PRIMARY KEY (book_id, editor_id)
);

CREATE TABLE essays (
	id serial primary key,
	question_id integer not null REFERENCES questions(id),
	writer_id integer not null REFERENCES writers(id),
	book_id integer not null REFERENCES books(id),
	started_at timestamp(0) with time zone,
	finished_at timestamp(0) with time zone,
	payable boolean,
	cleaned_at timestamp(0) with time zone,
	cleaned_by varchar(24),
	content text,
	comment text
);
CREATE INDEX esqi ON essays(question_id);
CREATE INDEX eswi ON essays(writer_id);
CREATE INDEX essa ON essays(started_at);
CREATE INDEX esfa ON essays(finished_at);
CREATE INDEX espy ON essays(payable);
CREATE INDEX esca ON essays(cleaned_at);

CREATE TABLE tags (
	id serial primary key,
	name varchar(16) UNIQUE
);

CREATE TABLE tidbits (
	id serial primary key,
	created_at date,
	created_by varchar(16),
	headline varchar(127),
	url text,
	intro text,
	content text
);

CREATE TABLE tags_tidbits (
	tag_id integer not null REFERENCES tags(id) ON DELETE CASCADE,
	tidbit_id integer not null REFERENCES tidbits(id) ON DELETE CASCADE,
	primary key (tag_id, tidbit_id)
);

CREATE TABLE questions_tidbits (
	question_id integer not null REFERENCES questions(id) ON DELETE CASCADE,
	tidbit_id integer not null REFERENCES tidbits(id) ON DELETE CASCADE,
	primary key (question_id, tidbit_id)
);

COMMIT;
