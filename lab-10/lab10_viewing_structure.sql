-- Lab 10: Viewing Database and Table Structure
-- Nurofarid Kukanbekova · AUCA · Databases
-- Runs on design_practice (the database built in Lab 09)

-- 1. \l: all databases on the server
\l

-- 2. \dt: tables in the current database
\dt
-- \dt+ also shows size and access method
\dt+

-- 3. \d students: columns, keys and who references this table
\d students

-- 4. \d loans: a table with defaults, NOT NULL and two foreign keys
\d loans

-- 5. \d+ books: extra detail (storage, statistics target, description)
\d+ books

-- 6. \di and \ds: indexes and sequences created automatically
\di
\ds

-- 7. The same information with SQL (information_schema)
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'loans'
ORDER BY ordinal_position;

-- 8. Every foreign key in the database (the edges of the ER diagram)
SELECT conrelid::regclass AS child_table,
       conname AS constraint_name,
       pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE contype = 'f'
ORDER BY conrelid::regclass::text;
