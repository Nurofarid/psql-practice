-- Basic Data Operations practice
-- Run from ~/psql-practice with: psql -d data_ops -f basic_data_operations_practice.sql

DROP TABLE IF EXISTS students;

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    birth_date DATE
);

-- INSERT one row
INSERT INTO students (first_name, last_name, birth_date)
VALUES ('Aibek', 'Sharshenov', '2002-05-12');

-- INSERT several rows at once
INSERT INTO students (first_name, last_name, birth_date) VALUES
    ('Ainura', 'Toktomamatova', '2001-09-23'),
    ('Bakyt', 'Mamatov', '2003-01-15'),
    ('Gulzat', 'Sultanova', '2002-07-30');
SELECT * FROM students ORDER BY student_id;

-- UPDATE (always with WHERE)
UPDATE students
SET birth_date = '2002-05-15'
WHERE first_name = 'Aibek' AND last_name = 'Sharshenov';

-- DELETE (always with WHERE)
DELETE FROM students
WHERE first_name = 'Gulzat' AND last_name = 'Sultanova';

DELETE FROM students
WHERE birth_date < '2002-01-01';
SELECT * FROM students ORDER BY student_id;

-- Bulk insert from a CSV file
-- \copy reads the file from your computer (path relative to where psql was started)
-- COPY ... FROM '/full/path/students.csv' does the same on the server side
\copy students(first_name, last_name, birth_date) FROM 'students.csv' DELIMITER ',' CSV HEADER
SELECT * FROM students ORDER BY student_id;

-- Bulk UPDATE
UPDATE students
SET last_name = 'Bekov'
WHERE last_name IN ('Uulu', 'Isakov');

-- Bulk DELETE
DELETE FROM students
WHERE student_id IN (2, 3, 5);
SELECT * FROM students ORDER BY student_id;

-- Safety net: try a dangerous command inside a transaction, then undo it
BEGIN;
DELETE FROM students;              -- no WHERE: deletes everything
SELECT COUNT(*) FROM students;     -- 0
ROLLBACK;                          -- undo
SELECT COUNT(*) FROM students;     -- rows are back

-- Export to CSV
\copy students TO 'students_export.csv' CSV HEADER
