-- Lab 04: First SQL Query
-- Run with: psql -d lab04_sql -f lab04_first_sql_query.sql

DROP TABLE IF EXISTS students;

-- Sample table used by all queries
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    name       VARCHAR(50),
    email      VARCHAR(100),
    faculty    VARCHAR(20)
);

INSERT INTO students (name, email, faculty) VALUES
('Alymbek', 'alymbek@example.com', 'COMSEH'),
('Timur',   'timur@example.com',   'MED'),
('Beka',    'beka@example.com',    'MAT');

-- 1. SQL syntax: keywords in UPPERCASE, names in snake_case
SELECT name, email FROM students WHERE faculty = 'COMSEH';

-- 2. SELECT structure: SELECT columns FROM table
SELECT name, email FROM students;

-- 3. First query: all columns and all rows
SELECT * FROM students;

-- 4. Understanding the result set: each row is a record, each column a field
SELECT student_id, faculty FROM students;

-- 5. Filtering with WHERE
SELECT name, email FROM students WHERE name = 'Timur';

-- 6. Sorting with ORDER BY (ASC is the default)
SELECT name, email FROM students ORDER BY name;
SELECT name, email FROM students ORDER BY name DESC;

-- 7. Limiting results with LIMIT (together with ORDER BY)
SELECT name, email FROM students ORDER BY name LIMIT 2;

-- 8. Comments
-- This query retrieves all students from the MED faculty.
SELECT name, faculty FROM students WHERE faculty = 'MED';

/* This is a multi-line comment.
   It can span multiple lines for detailed explanations. */
SELECT COUNT(*) AS total_students FROM students;
