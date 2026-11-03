-- Lab 11: Basic Data Operations
-- Nurofarid Kukanbekova · AUCA · Databases
-- Run from the lab-11 folder in a fresh database: data_ops

-- 1. INSERT: one row, then several rows at once
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    birth_date DATE
);
INSERT INTO students (first_name, last_name, birth_date)
VALUES ('Aibek', 'Sharshenov', '2002-05-12');
INSERT INTO students (first_name, last_name, birth_date) VALUES
    ('Ainura', 'Toktomamatova', '2001-09-23'),
    ('Bakyt', 'Mamatov', '2003-01-15'),
    ('Gulzat', 'Sultanova', '2002-07-30');
SELECT * FROM students ORDER BY student_id;

-- 2. UPDATE: change one row, found with WHERE
UPDATE students
SET birth_date = '2002-05-15'
WHERE first_name = 'Aibek' AND last_name = 'Sharshenov';
SELECT * FROM students WHERE first_name = 'Aibek';

-- 3. DELETE: by name, then by a condition on the date
DELETE FROM students
WHERE first_name = 'Gulzat' AND last_name = 'Sultanova';
-- removes everyone born before 2002 (Ainura)
DELETE FROM students
WHERE birth_date < '2002-01-01';
SELECT * FROM students ORDER BY student_id;

-- 4. Bulk insert from a CSV file
-- EXPECTED ERROR: server-side COPY looks for the file on the server, not in my folder
COPY students(first_name, last_name, birth_date)
FROM 'students.csv' DELIMITER ',' CSV HEADER;
-- \copy reads the file from my folder through psql
\copy students(first_name, last_name, birth_date) FROM 'students.csv' DELIMITER ',' CSV HEADER
SELECT * FROM students ORDER BY student_id;

-- 5. Bulk UPDATE and bulk DELETE
UPDATE students
SET last_name = 'Bekov'
WHERE last_name IN ('Uulu', 'Isakov');
DELETE FROM students
WHERE student_id IN (2, 3, 5);   -- 2 was already deleted, so only 3 and 5 go
SELECT * FROM students ORDER BY student_id;

-- 6. DELETE without WHERE removes every row (tested safely inside a transaction)
BEGIN;
DELETE FROM students;
SELECT count(*) AS rows_left FROM students;
ROLLBACK;
SELECT count(*) AS rows_after_rollback FROM students;

-- 7. Bulk export to a CSV file
\copy students TO 'students_export.csv' CSV HEADER
\! cat students_export.csv
