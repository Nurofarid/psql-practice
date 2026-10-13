-- Viewing Database and Table Structure practice
-- Run with: psql -d design_practice -f viewing_structure_practice.sql

-- List all databases
\l
-- List all tables in the current database
\dt
-- Tables with size
\dt+
-- Describe one table: columns, types, NOT NULL, defaults, keys
\d students
\d loans
-- More detail
\d+ books
-- Indexes (primary keys and UNIQUE create indexes automatically)
\di
-- Sequences (created by SERIAL)
\ds

-- The same information with SQL (information_schema)
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'loans'
ORDER BY ordinal_position;

-- All foreign keys = the lines of the ER diagram
SELECT conrelid::regclass  AS from_table,
       confrelid::regclass AS to_table,
       conname             AS constraint_name
FROM pg_constraint
WHERE contype = 'f'
ORDER BY conrelid::regclass::text;
