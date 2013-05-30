-- 2013-05-30
CREATE TABLE customers (
	id serial primary key,
	person_id integer not null UNIQUE
);
CREATE TABLE books_customers (
	book_id integer not null references books(id),
	customer_id integer not null references customers(id),
	primary key (book_id, customer_id)
);

-- 2013-05-29
ALTER TABLE books ADD COLUMN asin char(10);
ALTER TABLE books ADD COLUMN leanpub varchar(30);

-- 2013-05-21
ALTER TABLE books ADD COLUMN salescopy text;

-- 2013-04-26
ALTER TABLE answers RENAME COLUMN person_id TO researcher_id;
UPDATE answers SET researcher_id=1 WHERE researcher_id=327768;
UPDATE answers SET researcher_id=2 WHERE researcher_id=333347;
UPDATE answers SET researcher_id=3 WHERE researcher_id=333392;
UPDATE answers SET researcher_id=4 WHERE researcher_id=324695;
UPDATE answers SET researcher_id=5 WHERE researcher_id=327760;
UPDATE answers SET researcher_id=6 WHERE researcher_id=333466;
UPDATE answers SET researcher_id=7 WHERE researcher_id=313008;
UPDATE answers SET researcher_id=8 WHERE researcher_id=327755;
UPDATE answers SET researcher_id=9 WHERE researcher_id=310915;
UPDATE answers SET researcher_id=10 WHERE researcher_id=327765;
UPDATE answers SET researcher_id=11 WHERE researcher_id=327787;
UPDATE answers SET researcher_id=12 WHERE researcher_id=327763;
UPDATE answers SET researcher_id=13 WHERE researcher_id=327786;
UPDATE answers SET researcher_id=14 WHERE researcher_id=333622;
UPDATE answers SET researcher_id=15 WHERE researcher_id=306439;
UPDATE answers SET researcher_id=16 WHERE researcher_id=333342;
UPDATE answers SET researcher_id=17 WHERE researcher_id=333449;
UPDATE answers SET researcher_id=18 WHERE researcher_id=327757;
UPDATE answers SET researcher_id=19 WHERE researcher_id=327758;
UPDATE answers SET researcher_id=20 WHERE researcher_id=327759;
UPDATE answers SET researcher_id=21 WHERE researcher_id=327762;
UPDATE answers SET researcher_id=22 WHERE researcher_id=326583;
UPDATE answers SET researcher_id=23 WHERE researcher_id=327767;
UPDATE answers SET researcher_id=24 WHERE researcher_id=333884;
UPDATE answers SET researcher_id=25 WHERE researcher_id=333995;
UPDATE answers SET researcher_id=26 WHERE researcher_id=312089;
UPDATE answers SET researcher_id=27 WHERE researcher_id=335843;
UPDATE answers SET researcher_id=28 WHERE researcher_id=311591;
UPDATE answers SET researcher_id=29 WHERE researcher_id=324731;
UPDATE answers SET researcher_id=30 WHERE researcher_id=327752;
UPDATE answers SET researcher_id=31 WHERE researcher_id=327840;
UPDATE answers SET researcher_id=32 WHERE researcher_id=305369;
UPDATE answers SET researcher_id=33 WHERE researcher_id=323938;
UPDATE answers SET researcher_id=34 WHERE researcher_id=327761;
UPDATE answers SET researcher_id=35 WHERE researcher_id=327754;
UPDATE answers SET researcher_id=36 WHERE researcher_id=327764;
UPDATE answers SET researcher_id=37 WHERE researcher_id=327775;
UPDATE answers SET researcher_id=38 WHERE researcher_id=320686;
UPDATE answers SET researcher_id=39 WHERE researcher_id=322353;
UPDATE answers SET researcher_id=40 WHERE researcher_id=327766;
UPDATE answers SET researcher_id=41 WHERE researcher_id=327848;
UPDATE answers SET researcher_id=42 WHERE researcher_id=327856;
UPDATE answers SET researcher_id=43 WHERE researcher_id=314333;
UPDATE answers SET researcher_id=44 WHERE researcher_id=327748;
UPDATE answers SET researcher_id=45 WHERE researcher_id=327753;
UPDATE answers SET researcher_id=46 WHERE researcher_id=59196;
UPDATE answers SET researcher_id=47 WHERE researcher_id=327776;
UPDATE answers SET researcher_id=48 WHERE researcher_id=333402;
UPDATE answers SET researcher_id=49 WHERE researcher_id=333445;
UPDATE answers SET researcher_id=50 WHERE researcher_id=334038;
UPDATE answers SET researcher_id=51 WHERE researcher_id=334039;
ALTER TABLE answers ADD FOREIGN KEY (researcher_id) REFERENCES researchers(id);

INSERT INTO editors (person_id) VALUES (1);      -- 4
INSERT INTO editors (person_id) VALUES (338873); -- 5
ALTER TABLE essays RENAME COLUMN person_id TO editor_id;
UPDATE essays SET editor_id=4 WHERE editor_id=1;
UPDATE essays SET editor_id=5 WHERE editor_id=338873;
UPDATE essays SET editor_id=1 WHERE editor_id=331600;
UPDATE essays SET editor_id=2 WHERE editor_id=331709;
UPDATE essays SET editor_id=3 WHERE editor_id=338825;
ALTER TABLE essays ADD FOREIGN KEY (editor_id) REFERENCES editors(id);

