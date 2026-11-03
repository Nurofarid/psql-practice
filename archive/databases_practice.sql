-- Databases lesson practice

-- Create a database
CREATE DATABASE university;

-- Switch into it (psql command):
-- \c university

-- Cannot drop the database you are connected to:
-- DROP DATABASE university;   -> ERROR: cannot drop the currently open database

-- Switch to another database first, then drop:
-- \c postgres
DROP DATABASE university;

-- Naming conventions: lowercase + snake_case
CREATE DATABASE student_records;
DROP DATABASE student_records;

-- Reserved keyword fails:
-- CREATE DATABASE select;     -> syntax error

-- Connect directly from the terminal:
-- psql -d university
