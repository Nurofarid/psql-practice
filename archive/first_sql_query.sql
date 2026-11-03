-- First SQL Query practice

DROP TABLE IF EXISTS students;

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

SELECT * FROM students;
SELECT name, email FROM students WHERE name = 'Timur';
SELECT name, email FROM students ORDER BY name;
SELECT name, email FROM students ORDER BY name LIMIT 2;
SELECT name, email FROM students ORDER BY name DESC;
SELECT name, faculty FROM students WHERE faculty = 'MED';
