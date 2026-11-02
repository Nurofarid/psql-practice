-- Lab 05: Databases
-- Run with: bash run.sh   (it removes leftovers from earlier runs first)
-- Contains 3 EXPECTED errors (marked below).

-- 1. CREATE DATABASE
CREATE DATABASE university;
\l university

-- 2. Switching between databases with \c
\c university
SELECT current_database();

-- 3. EXPECTED ERROR: a database cannot be dropped while you are connected to it
DROP DATABASE university;

-- 4. Connect to another database, then DROP DATABASE works
\c postgres
DROP DATABASE university;
\l university

-- 5. Naming conventions
-- Good: lowercase snake_case
CREATE DATABASE student_records;
-- Unquoted names are folded to lowercase: StudentDB becomes studentdb
CREATE DATABASE StudentDB;
-- With double quotes the capital letters are kept, and the name must then always be quoted
CREATE DATABASE "StudentDB";
\l *tudent*
-- EXPECTED ERROR: spaces are not allowed in unquoted names
CREATE DATABASE course management;
-- EXPECTED ERROR: reserved keywords cannot be used as names
CREATE DATABASE select;

-- Clean up
DROP DATABASE student_records;
DROP DATABASE studentdb;
DROP DATABASE "StudentDB";
