-- Lab 06: Tables, Data Types and Constraints
-- Run with: bash run.sh   (uses the "university" database from Lab 05)
-- Contains 6 EXPECTED errors (marked below).

-- 1. CREATE TABLE: name, columns, data types, constraints
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    faculty    VARCHAR(100)
);
\d students

INSERT INTO students (first_name, last_name, email, faculty) VALUES
('Alymbek', 'Asanov', 'alymbek@auca.kg', 'Software Engineering'),
('Timur',   'Bekov',  'timur@auca.kg',   'Applied Mathematics');
SELECT * FROM students;

-- 2. Constraints protect the data
-- EXPECTED ERROR: NOT NULL (last_name is required)
INSERT INTO students (first_name, last_name, email) VALUES ('Beka', NULL, 'beka@auca.kg');
-- EXPECTED ERROR: UNIQUE (this email is already used)
INSERT INTO students (first_name, last_name, email) VALUES ('Beka', 'Osmonov', 'timur@auca.kg');

-- 3. More data types + CHECK and FOREIGN KEY
CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,                                 -- auto-incrementing integer
    student_id    INTEGER REFERENCES students(student_id),            -- FOREIGN KEY
    course_name   TEXT NOT NULL,                                      -- text without a length limit
    grade         INTEGER CHECK (grade >= 0 AND grade <= 100),        -- CHECK
    is_active     BOOLEAN DEFAULT TRUE,                               -- true / false
    enrolled_on   DATE,                                               -- date
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,                -- date and time
    credits_total BIGINT                                              -- large whole number
);
INSERT INTO enrollments (student_id, course_name, grade, enrolled_on, credits_total)
VALUES (1, 'Databases', 95, '2026-09-01', 6);
SELECT enrollment_id, student_id, course_name, grade, is_active, enrolled_on FROM enrollments;
-- EXPECTED ERROR: CHECK (grade must be between 0 and 100)
INSERT INTO enrollments (student_id, course_name, grade) VALUES (1, 'Statistics', 150);
-- EXPECTED ERROR: FOREIGN KEY (student 99 does not exist)
INSERT INTO enrollments (student_id, course_name, grade) VALUES (99, 'Statistics', 80);

-- 4. DROP TABLE
-- EXPECTED ERROR: the table does not exist
DROP TABLE non_existing_table;
-- With IF EXISTS: only a NOTICE, no error
DROP TABLE IF EXISTS non_existing_table;

-- 5. ALTER TABLE: change the structure without recreating the table
-- 5.1 Adding a column
ALTER TABLE students
ADD COLUMN date_of_birth DATE;
-- 5.2 Dropping a column
ALTER TABLE students
DROP COLUMN faculty;
-- 5.3 Changing a column's data type
ALTER TABLE students
ALTER COLUMN first_name TYPE TEXT;
-- 5.4 Adding a constraint
ALTER TABLE students
ADD CONSTRAINT unique_student_email UNIQUE (email);
-- 5.5 Renaming a column and the table
ALTER TABLE students
RENAME COLUMN email TO email_address;
ALTER TABLE students
RENAME TO university_students;

\d university_students
-- The foreign key in enrollments followed the renamed table automatically
\d enrollments

-- 6. Temporary table: exists only during the current session
CREATE TEMP TABLE temp_scores (student_name VARCHAR(50), score INTEGER);
INSERT INTO temp_scores VALUES ('Timur', 88), ('Alymbek', 92);
SELECT * FROM temp_scores;
-- Reconnect = start a new session
\c university
-- EXPECTED ERROR: the temporary table was dropped when the session ended
SELECT * FROM temp_scores;
\dt
