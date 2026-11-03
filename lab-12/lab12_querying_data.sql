-- Lab 12: Querying Data
-- Nurofarid Kukanbekova · AUCA · Databases
-- Run in a fresh database: query_practice

-- 1. Sample data for this lab
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    department VARCHAR(30),
    department_id INT,
    salary NUMERIC(10,2),
    email VARCHAR(100)
);
INSERT INTO employees (name, department, department_id, salary, email) VALUES
    ('Aibek Sharshenov',     'Engineering', 3, 120000, 'aibek@company.kg'),
    ('Ainura Toktomamatova', 'Sales',       5,  65000, 'ainura@company.kg'),
    ('Bakyt Mamatov',        'Engineering', 3,  80000, 'bakyt@company.kg'),
    ('Gulzat Sultanova',     'Marketing',   7,  55000, NULL),
    ('Brandon Lee',          'Sales',       5,  90000, 'brandon@company.kg'),
    ('Meerim Bekova',        'HR',          2,  48000, 'meerim@company.kg'),
    ('Timur Asanov',         'Engineering', 3,  70000, NULL),
    ('Aida Karimova',        'Marketing',   7, 102000, 'aida@company.kg');
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    amount NUMERIC(10,2)
);
INSERT INTO sales (employee_id, amount) VALUES
    (2, 1500), (2, 400), (5, 2500), (4, 800), (8, 1200);
CREATE TABLE products (product_name VARCHAR(50), price NUMERIC(6,2));
INSERT INTO products VALUES
    ('Strawberry jam', 12.50), ('Blueberry yogurt', 24.00), ('Raspberry tea', 35.00),
    ('Apple juice', 18.00), ('Mountain honey', 48.00), ('Cranberry juice', 55.00);
CREATE TABLE customers (customer_name VARCHAR(50));
INSERT INTO customers VALUES
    ('Brad Johnson'), ('Brandon Kim'), ('bravo store'), ('Bakyt Usenov'), ('Aliya Rysbekova');
CREATE TABLE users (email VARCHAR(100));
INSERT INTO users VALUES
    ('aibek@gmail.com'), ('AINURA@GMAIL.COM'), ('timur@mail.ru'),
    ('meerim.bekova@auca.kg'), ('bad-email@'), ('no at sign.com');

-- 2. SELECT: all columns, then only some columns
SELECT * FROM employees;
SELECT name, department FROM employees;

-- 3. Calculations and aliases with AS
SELECT name, salary, salary * 0.10 AS potential_bonus
FROM employees;
-- EXPECTED ERROR: an alias from SELECT cannot be used in WHERE (WHERE runs first)
SELECT name, salary * 0.10 AS potential_bonus
FROM employees
WHERE potential_bonus > 8000;

-- 4. WHERE: comparison, AND/OR/NOT, BETWEEN, IS NULL
SELECT name, salary FROM employees WHERE department = 'Sales';
SELECT name FROM employees WHERE salary > 75000 AND department = 'Engineering';
SELECT name, department FROM employees
WHERE department = 'HR' OR NOT salary < 100000;
SELECT product_name, price FROM products WHERE price BETWEEN 20 AND 50;
SELECT name FROM employees WHERE email IS NULL;

-- 5. Pattern matching: LIKE (case-sensitive) and ILIKE (case-insensitive)
SELECT customer_name FROM customers WHERE customer_name LIKE 'Bra%';
SELECT customer_name FROM customers WHERE customer_name ILIKE 'bra%';
SELECT product_name FROM products WHERE product_name LIKE '%berry%';
SELECT email FROM users WHERE email ILIKE '%@gmail.com';
-- _ is exactly one character: four-letter first names
SELECT name FROM employees WHERE name LIKE '____ %';

-- 6. Regular expressions: ~  ~*  !~
SELECT name FROM employees WHERE name ~ '^[AB]';
SELECT email FROM users
WHERE email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$';
SELECT email AS invalid_email FROM users
WHERE email !~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$';

-- 7. IN and EXISTS
SELECT name, department FROM employees WHERE department_id IN (3, 5, 7);
SELECT name FROM employees
WHERE id IN (SELECT employee_id FROM sales WHERE amount > 1000);
SELECT name FROM employees e
WHERE EXISTS (
    SELECT 1 FROM sales s
    WHERE s.employee_id = e.id AND s.amount > 1000
);
-- NOT EXISTS: employees with no sales at all
SELECT name FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM sales s WHERE s.employee_id = e.id)
ORDER BY e.id;

-- 8. CASE: IF-THEN-ELSE inside a query
SELECT name, salary,
    CASE
        WHEN salary > 100000 THEN 'Senior'
        WHEN salary BETWEEN 60000 AND 100000 THEN 'Mid-Level'
        ELSE 'Junior'
    END AS employee_level
FROM employees
ORDER BY salary DESC;

-- 9. CTE (WITH): employees who earn more than their department average
WITH department_averages AS (
    SELECT department, ROUND(AVG(salary), 2) AS avg_salary
    FROM employees
    GROUP BY department
)
SELECT e.name, e.salary, e.department, da.avg_salary
FROM employees e
JOIN department_averages da ON e.department = da.department
WHERE e.salary > da.avg_salary;
