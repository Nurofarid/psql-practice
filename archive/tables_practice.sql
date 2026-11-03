-- Tables, Data Types and Constraints practice
-- Run with: psql -d university -f tables_practice.sql

DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS students;

-- CREATE TABLE with constraints
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    faculty    VARCHAR(100)
);

INSERT INTO students (first_name, last_name, email, faculty) VALUES
('Alymbek', 'Asanov', 'alymbek@example.com', 'COMSEH'),
('Timur',   'Bekov',  'timur@example.com',   'MED');

-- Constraint violations (each fails):
-- NOT NULL:    INSERT ... last_name = NULL
-- UNIQUE:      INSERT ... duplicate email
-- PRIMARY KEY: INSERT ... duplicate student_id

-- CHECK, FOREIGN KEY, DATE, BOOLEAN, DEFAULT
CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id    INTEGER REFERENCES students(student_id),
    course_name   VARCHAR(100) NOT NULL,
    grade         INTEGER CHECK (grade >= 0 AND grade <= 100),
    enrolled_on   DATE,
    is_active     BOOLEAN DEFAULT TRUE
);

INSERT INTO enrollments (student_id, course_name, grade, enrolled_on)
VALUES (1, 'Databases', 95, '2026-09-01');
-- grade 150   -> violates CHECK
-- student 99  -> violates FOREIGN KEY

-- ALTER TABLE
ALTER TABLE students ADD COLUMN enrollment_year INTEGER;
ALTER TABLE students ALTER COLUMN faculty TYPE VARCHAR(150);
ALTER TABLE students ADD CONSTRAINT chk_enrollment_year CHECK (enrollment_year >= 2000);
ALTER TABLE students RENAME COLUMN faculty TO department;
ALTER TABLE students DROP COLUMN enrollment_year;

CREATE TABLE test_table (id SERIAL PRIMARY KEY, note TEXT);
ALTER TABLE test_table RENAME TO practice_table;

-- DROP TABLE
DROP TABLE practice_table;
DROP TABLE IF EXISTS practice_table;

-- Temporary table (deleted when the session ends)
CREATE TEMP TABLE temp_scores (student_name VARCHAR(50), score INTEGER);
INSERT INTO temp_scores VALUES ('Timur', 88), ('Alymbek', 92);
SELECT * FROM temp_scores;

SELECT * FROM students;
SELECT * FROM enrollments;
