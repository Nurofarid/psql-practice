-- Lab 03: Basic psql Commands
-- Run with: psql -d lab03_psql -f lab03_basic_psql.sql

-- 1. Meta-commands: look around
\l
\conninfo
-- The new database is empty, so \dt finds no tables yet
\dt

-- 2. Connect to a database
\c lab03_psql

-- 3. Create a table
CREATE TABLE students (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(100),
    age  INT
);

-- 4. List tables and describe the new one
\dt
\d students

-- 5. Insert data
INSERT INTO students (name, age) VALUES ('Alice', 21), ('Bob', 23);

-- 6. Select data
SELECT * FROM students;

-- 7. Help on an SQL command
\h DROP TABLE

-- 8. Delete the table
DROP TABLE students;

-- 9. Check: the table is gone
\d students
