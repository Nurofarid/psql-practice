-- Lab 17: Data Import/Export and Backup (part 1: COPY and CSV)
-- Nurofarid Kukanbekova · AUCA · Databases
-- Runs in shop_db from the lab-17 folder; files go to lab-17/files/

-- 1. Sample tables
CREATE TABLE employees (
    id SERIAL PRIMARY KEY, first_name VARCHAR(30), last_name VARCHAR(30),
    email VARCHAR(50), department VARCHAR(20)
);
INSERT INTO employees (first_name, last_name, email, department) VALUES
    ('Aibek', 'Sharshenov', 'aibek@co.kg', 'IT'), ('Ainura', 'Toktomamatova', NULL, 'Sales'),
    ('Bakyt', 'Mamatov', 'bakyt@co.kg', 'IT'), ('Meerim', 'Bekova', 'meerim@co.kg', 'HR');
CREATE TABLE products (id INT PRIMARY KEY, name VARCHAR(50), price NUMERIC(8,2));
INSERT INTO products VALUES (1, 'Laptop', 1200.00), (2, 'Phone', 650.00), (3, 'Headphones', 80.00);
CREATE TABLE orders (order_id INT PRIMARY KEY, customer VARCHAR(30), order_date DATE, total NUMERIC(8,2));
INSERT INTO orders VALUES (1, 'Aida', '2026-10-01', 250.00), (2, 'Timur', '2026-10-15', 45.50);
CREATE TABLE customer_feedback (id INT, comment TEXT);
INSERT INTO customer_feedback VALUES
    (1, 'Fast delivery, good price'), (2, 'The box said "fragile", but it was fine');
CREATE TABLE log_table (id SERIAL, message TEXT);
INSERT INTO log_table (message) VALUES ('debug 1'), ('debug 2');

-- 2. Server-side COPY: the PostgreSQL server itself writes the file
COPY (SELECT * FROM employees WHERE department = 'IT') TO '/tmp/it_employees.csv' WITH CSV HEADER;
\! cat /tmp/it_employees.csv

-- 3. Export with \copy (psql writes the file in my folder) and different options
\copy products TO 'files/products.csv' WITH CSV HEADER
\! cat files/products.csv
\copy employees TO 'files/employees.txt' WITH DELIMITER '|' NULL 'N/A' CSV HEADER
\! cat files/employees.txt
\copy employees TO 'files/customers_semicolon.csv' WITH CSV HEADER DELIMITER ';' QUOTE '"'
\! cat files/customers_semicolon.csv
\copy orders TO 'files/orders.csv' WITH (FORMAT csv, HEADER, FORCE_QUOTE (order_date))
\! cat files/orders.csv
\copy customer_feedback TO 'files/feedback.csv' WITH CSV HEADER DELIMITER ',' QUOTE '"' ESCAPE '"'
\! cat files/feedback.csv

-- 4. Import: a full table, specific columns, custom NULL text
CREATE TABLE products_copy (LIKE products);
\copy products_copy FROM 'files/products.csv' WITH CSV HEADER ENCODING 'UTF8'
SELECT * FROM products_copy;
\! printf 'first_name,last_name,email\nTilek,Usubaliev,tilek@co.kg\nGulzat,Sultanova,NULL\n' > files/new_employees.csv
\copy employees(first_name, last_name, email) FROM 'files/new_employees.csv' WITH CSV HEADER NULL 'NULL'
SELECT id, first_name, email, department FROM employees WHERE id > 4;
-- the feedback with commas and quotes comes back exactly the same
CREATE TABLE feedback_copy (LIKE customer_feedback);
\copy feedback_copy FROM 'files/feedback.csv' WITH CSV HEADER
SELECT * FROM feedback_copy;

-- 5. Import with bad rows
\! printf 'id,name,price\n10,Mouse,25.00\n11,Keyboard,not-a-price\n12,Monitor,300.00\n' > files/products_with_errors.csv
-- EXPECTED ERROR: without ON_ERROR the whole COPY stops at the bad price
\copy products FROM 'files/products_with_errors.csv' WITH CSV HEADER
SELECT count(*) AS products_after_failed_copy FROM products;
-- ON_ERROR IGNORE (PostgreSQL 17+) skips the bad row and loads the rest
\copy products FROM 'files/products_with_errors.csv' WITH (FORMAT csv, HEADER, ON_ERROR ignore)
SELECT * FROM products ORDER BY id;
