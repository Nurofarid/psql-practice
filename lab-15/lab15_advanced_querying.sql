-- Lab 15: Advanced Querying
-- Nurofarid Kukanbekova · AUCA · Databases
-- Run in a fresh database: advanced_practice

-- 1. Sample data: employees with managers, regional orders
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(30), last_name VARCHAR(30), department VARCHAR(30),
    salary NUMERIC(10,2), tenure INT,
    manager_id INT REFERENCES employees(employee_id)
);
INSERT INTO employees (first_name, last_name, department, salary, tenure, manager_id) VALUES
    ('Aibek',     'Sharshenov',    'Management',  150000, 12, NULL),
    ('Ainura',    'Toktomamatova', 'Sales',        90000,  8, 1),
    ('Bakyt',     'Mamatov',       'Engineering', 110000,  7, 1),
    ('Brandon',   'Lee',           'Sales',        70000,  3, 2),
    ('Tilek',     'Usubaliev',     'Sales',        70000,  6, 2),
    ('Timur',     'Asanov',        'Engineering',  95000,  2, 3),
    ('Nursultan', 'Isakov',        'Engineering',  95000,  6, 3),
    ('Meerim',    'Bekova',        'Engineering',  60000,  1, 6);
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY, region_id INT, product_name VARCHAR(30),
    status VARCHAR(20), amount NUMERIC(12,2)
);
INSERT INTO orders (region_id, product_name, status, amount) VALUES
    (1, 'Laptop',   'Low Priority',    650000), (1, 'Phone',    'High Priority',   480000),
    (2, 'Laptop',   'Medium Priority', 300000), (2, 'Tablet',   'High Priority',   250000),
    (3, 'Phone',    'Low Priority',    900000), (3, 'Monitor',  'Medium Priority', 400000),
    (4, 'Keyboard', 'Shipped',          20000);

-- 2. Subqueries: scalar, row and table
-- scalar: one value (the company average)
SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
-- row: one row with two columns, compared as a pair
SELECT first_name, department, salary
FROM employees
WHERE (department, salary) = (SELECT department, salary FROM employees WHERE first_name = 'Tilek')
  AND first_name <> 'Tilek';
-- table: a whole result set used in FROM
SELECT department, avg_salary
FROM (SELECT department, ROUND(AVG(salary), 2) AS avg_salary
      FROM employees GROUP BY department) AS dept_avg
WHERE avg_salary > 80000
ORDER BY avg_salary DESC;

-- 3. CTE: regions with more than 1 000 000 in sales
WITH regional_sales AS (
    SELECT region_id, SUM(amount) AS total_sales
    FROM orders
    GROUP BY region_id
)
SELECT region_id, total_sales
FROM regional_sales
WHERE total_sales > 1000000
ORDER BY region_id;

-- 4. Recursive CTE: the whole org chart from the top manager down
WITH RECURSIVE org_chart AS (
    SELECT employee_id, first_name, last_name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.first_name, e.last_name, e.manager_id, oc.level + 1
    FROM employees e
    INNER JOIN org_chart oc ON e.manager_id = oc.employee_id
)
SELECT level, repeat('    ', level - 1) || first_name || ' ' || last_name AS employee, manager_id
FROM org_chart
ORDER BY level, employee_id;
-- EXPECTED ERROR: without the word RECURSIVE the CTE cannot refer to itself
WITH org_chart AS (
    SELECT employee_id, manager_id FROM employees WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.manager_id FROM employees e JOIN org_chart oc ON e.manager_id = oc.employee_id
)
SELECT * FROM org_chart;

-- 5. Set operations: UNION removes duplicates, UNION ALL keeps them
CREATE TABLE warehouse_1 (product_id INT, product_name VARCHAR(30), quantity INT);
CREATE TABLE warehouse_2 (product_id INT, product_name VARCHAR(30), quantity INT);
INSERT INTO warehouse_1 VALUES (1, 'Laptop', 5), (2, 'Phone', 0), (3, 'Tablet', 0), (4, 'Mouse', 12);
INSERT INTO warehouse_2 VALUES (2, 'Phone', 0), (3, 'Tablet', 7), (5, 'Monitor', 0), (1, 'Laptop', 2);
SELECT product_name FROM warehouse_1 UNION SELECT product_name FROM warehouse_2 ORDER BY 1;
SELECT product_name FROM warehouse_1 UNION ALL SELECT product_name FROM warehouse_2 ORDER BY 1;

-- 6. Set operations: INTERSECT and EXCEPT
-- out of stock in both warehouses
SELECT product_id FROM warehouse_1 WHERE quantity = 0
INTERSECT
SELECT product_id FROM warehouse_2 WHERE quantity = 0;
-- products that only warehouse 1 has
SELECT product_name FROM warehouse_1 EXCEPT SELECT product_name FROM warehouse_2;
-- EXPECTED ERROR: both sides of UNION must have the same number of columns
SELECT product_id, product_name FROM warehouse_1 UNION SELECT product_id FROM warehouse_2;

-- 7. Window functions: RANK, DENSE_RANK, ROW_NUMBER, running SUM
SELECT first_name, department, salary,
       RANK()       OVER (PARTITION BY department ORDER BY salary DESC) AS dept_salary_rank,
       DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dense_rank,
       ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS row_number
FROM employees
ORDER BY department, salary DESC;
SELECT first_name, salary,
       SUM(salary) OVER (ORDER BY employee_id) AS running_total
FROM employees;

-- 8. LAG and LEAD: compare a row with the previous / next one
SELECT first_name, salary,
       LAG(salary)  OVER (ORDER BY salary) AS previous_salary,
       LEAD(salary) OVER (ORDER BY salary) AS next_salary,
       salary - LAG(salary) OVER (ORDER BY salary) AS gap_to_previous
FROM employees
ORDER BY salary;

-- 9. Pivot (rows to columns) and unpivot (columns to rows)
CREATE TABLE sales (product_name VARCHAR(30), year INT, sales_amount NUMERIC(10,2));
INSERT INTO sales VALUES
    ('Laptop', 2022, 1200), ('Laptop', 2023, 1500), ('Laptop', 2024, 1800),
    ('Phone',  2022, 2000), ('Phone',  2023, 1700), ('Phone',  2024, 2100),
    ('Tablet', 2023,  600), ('Tablet', 2024,  900);
CREATE TABLE pivoted_sales AS
SELECT product_name,
       SUM(CASE WHEN year = 2022 THEN sales_amount ELSE 0 END) AS year_2022,
       SUM(CASE WHEN year = 2023 THEN sales_amount ELSE 0 END) AS year_2023,
       SUM(CASE WHEN year = 2024 THEN sales_amount ELSE 0 END) AS year_2024
FROM sales
GROUP BY product_name;
SELECT * FROM pivoted_sales ORDER BY product_name;
SELECT product_name, '2022' AS year, year_2022 AS sales_amount FROM pivoted_sales
UNION ALL
SELECT product_name, '2023' AS year, year_2023 AS sales_amount FROM pivoted_sales
UNION ALL
SELECT product_name, '2024' AS year, year_2024 AS sales_amount FROM pivoted_sales
ORDER BY product_name, year;

-- 10. Complex filtering (FILTER) and custom sorting (CASE in ORDER BY)
SELECT employee_id, first_name, department, tenure,
       SUM(salary) OVER (PARTITION BY department) AS total_dept_salary,
       ROUND(AVG(salary) FILTER (WHERE tenure > 5) OVER (), 2) AS avg_salary_senior
FROM employees
ORDER BY employee_id;
SELECT product_name, status
FROM orders
ORDER BY
    CASE status
        WHEN 'High Priority'   THEN 1
        WHEN 'Medium Priority' THEN 2
        WHEN 'Low Priority'    THEN 3
        ELSE 4
    END, product_name;

-- 11. Query optimization: EXPLAIN before and after an index
CREATE TABLE big_orders AS
SELECT g AS order_id, (g % 5000) + 1 AS customer_id, (g % 997) * 1.5 AS amount
FROM generate_series(1, 200000) g;
ANALYZE big_orders;
EXPLAIN SELECT * FROM big_orders WHERE customer_id = 42;
CREATE INDEX idx_big_orders_customer ON big_orders(customer_id);
EXPLAIN SELECT * FROM big_orders WHERE customer_id = 42;
EXPLAIN ANALYZE SELECT order_id, amount FROM big_orders WHERE customer_id = 42 LIMIT 10;
