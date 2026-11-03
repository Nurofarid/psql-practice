-- Lab 13: Aggregate Functions
-- Nurofarid Kukanbekova · AUCA · Databases
-- Run in a fresh database: agg_practice

-- 1. Sample data for this lab
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(30), last_name VARCHAR(30),
    department VARCHAR(30), salary NUMERIC(10,2), age INT,
    hire_date DATE, email VARCHAR(50), bonus NUMERIC(8,2), experience_years INT
);
INSERT INTO employees (first_name, last_name, department, salary, age, hire_date, email, bonus, experience_years) VALUES
    ('Aibek',     'Sharshenov',    'Engineering', 120000, 34, '2019-03-01', 'aibek@co.kg',     10000, 10),
    ('Ainura',    'Toktomamatova', 'Sales',        65000, 27, '2022-06-15', 'ainura@co.kg',     3000,  4),
    ('Bakyt',     'Mamatov',       'Engineering',  80000, 29, '2021-09-01', 'bakyt@co.kg',      NULL,  6),
    ('Gulzat',    'Sultanova',     'Marketing',    55000, 24, '2023-02-10', NULL,               NULL,  2),
    ('Brandon',   'Lee',           'Sales',        90000, 41, '2017-11-20', 'brandon@co.kg',    5000, 15),
    ('Meerim',    'Bekova',        'HR',           48000, 23, '2024-01-08', 'meerim@co.kg',     NULL,  1),
    ('Timur',     'Asanov',        'Engineering',  70000, 26, '2023-07-03', NULL,               2000,  3),
    ('Aida',      'Karimova',      'Marketing',   102000, 52, '2012-05-14', 'aida@co.kg',       8000, 22),
    ('Nursultan', 'Isakov',        'Engineering',  95000, 38, '2018-04-23', 'nursultan@co.kg',  NULL, 12),
    ('Tilek',     'Usubaliev',     'Sales',        52000, 55, '2010-08-30', 'tilek@co.kg',      1500, 25);
CREATE TABLE employee_skills (employee_id INT REFERENCES employees, skill_name VARCHAR(30));
INSERT INTO employee_skills VALUES
    (1, 'SQL'), (1, 'Python'), (1, 'Docker'), (2, 'Negotiation'), (2, 'Excel'),
    (3, 'SQL'), (3, 'Java'), (5, 'CRM'), (5, 'Excel');
CREATE TABLE products (product_id SERIAL PRIMARY KEY, name VARCHAR(30), category VARCHAR(20), price NUMERIC(8,2));
INSERT INTO products (name, category, price) VALUES
    ('Laptop', 'Electronics', 1200), ('Phone', 'Electronics', 650), ('Headphones', 'Electronics', 80), ('SQL Guide', 'Books', 40),
    ('Jamilia', 'Books', 15), ('Mountain honey', 'Food', 12), ('Apricot jam', 'Food', 6);
CREATE TABLE sales (sale_id SERIAL PRIMARY KEY, sale_date DATE, department VARCHAR(30), amount NUMERIC(10,2));
INSERT INTO sales (sale_date, department, amount) VALUES
    ('2025-08-12', 'Sales', 1200), ('2025-11-03', 'Sales', 800), ('2025-12-20', 'Marketing', 450),
    ('2026-01-15', 'Sales', 2500), ('2026-02-28', 'Marketing', 300), ('2026-03-10', 'Sales', 950),
    ('2026-05-05', 'Sales', 1700), ('2026-08-19', 'Marketing', 600), ('2026-09-01', 'Sales', 1100);
CREATE TABLE product_reviews (product_id INT, rating INT);   -- filled with generate_series
INSERT INTO product_reviews SELECT 1, 4 + g % 2       FROM generate_series(1, 12) g;
INSERT INTO product_reviews SELECT 2, 3 + (g % 3 > 0)::int FROM generate_series(1, 12) g;
INSERT INTO product_reviews SELECT 3, 5               FROM generate_series(1, 5) g;

-- 2. COUNT, SUM, AVG, MAX, MIN on the whole table
SELECT COUNT(*) AS total_employees FROM employees;
SELECT COUNT(email) AS employees_with_email FROM employees;
SELECT COUNT(DISTINCT department) AS unique_departments FROM employees;
SELECT SUM(salary) AS total_salaries FROM employees;
SELECT AVG(salary) AS average_salary FROM employees;
SELECT MAX(salary) AS highest_salary, MIN(salary) AS lowest_salary FROM employees;

-- 3. Aggregates per group with GROUP BY
SELECT department, SUM(amount) AS total_sales FROM sales GROUP BY department;
SELECT department, ROUND(AVG(age), 1) AS avg_age FROM employees GROUP BY department ORDER BY department;
SELECT department, MAX(hire_date) AS latest_hire FROM employees GROUP BY department ORDER BY department;
-- EXPECTED ERROR: department is neither grouped nor aggregated
SELECT department, COUNT(*) FROM employees;

-- 4. STRING_AGG and ARRAY_AGG: many rows into one value
SELECT department, STRING_AGG(first_name, ', ') AS employee_names
FROM employees GROUP BY department ORDER BY department;
SELECT employee_id, STRING_AGG(skill_name, ', ' ORDER BY skill_name) AS skills
FROM employee_skills GROUP BY employee_id ORDER BY employee_id;
SELECT department, ARRAY_AGG(salary) AS salary_array
FROM employees GROUP BY department ORDER BY department;
SELECT department, ARRAY_AGG(first_name ORDER BY last_name) AS employees
FROM employees GROUP BY department ORDER BY department;

-- 5. Statistical aggregates: STDDEV, VARIANCE, CORR
SELECT department,
       ROUND(STDDEV(salary), 2) AS salary_std_dev,
       ROUND(VARIANCE(salary), 0) AS salary_variance
FROM employees GROUP BY department ORDER BY department;
SELECT ROUND(CORR(experience_years, salary)::numeric, 3) AS experience_salary_correlation
FROM employees;

-- 6. GROUP BY: by one column, by two columns, by an expression
SELECT category, COUNT(*) AS number_of_products, SUM(price) AS total_value,
       ROUND(AVG(price), 2) AS average_price
FROM products GROUP BY category ORDER BY category;
SELECT EXTRACT(YEAR FROM sale_date) AS year, EXTRACT(QUARTER FROM sale_date) AS quarter,
       COUNT(*) AS total_sales, SUM(amount) AS total_revenue
FROM sales
GROUP BY EXTRACT(YEAR FROM sale_date), EXTRACT(QUARTER FROM sale_date)
ORDER BY year, quarter;
SELECT CASE WHEN age < 30 THEN 'Under 30'
            WHEN age BETWEEN 30 AND 50 THEN '30-50'
            ELSE 'Over 50' END AS age_group,
       COUNT(*) AS employee_count, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY 1
ORDER BY 1;

-- 7. HAVING: filter groups after grouping
SELECT department, COUNT(*) AS employee_count
FROM employees GROUP BY department HAVING COUNT(*) > 5;
SELECT department, COUNT(*) AS employee_count
FROM employees GROUP BY department HAVING COUNT(*) > 2 ORDER BY department;
SELECT product_id, ROUND(AVG(rating), 2) AS avg_rating, COUNT(*) AS review_count
FROM product_reviews GROUP BY product_id
HAVING AVG(rating) > 4.0 AND COUNT(*) >= 10;
-- WHERE (before grouping) and HAVING (after grouping) together
SELECT department, COUNT(*) AS seniors
FROM employees WHERE age >= 30 GROUP BY department HAVING COUNT(*) >= 2;
-- EXPECTED ERROR: aggregates are not allowed in WHERE
SELECT department FROM employees WHERE COUNT(*) > 2 GROUP BY department;

-- 8. Aggregate vs window function
SELECT department, ROUND(AVG(salary), 2) AS dept_avg_salary
FROM employees GROUP BY department ORDER BY department;
SELECT employee_id, first_name, department, salary,
       ROUND(AVG(salary) OVER (PARTITION BY department), 2) AS dept_avg_salary
FROM employees ORDER BY department, employee_id;

-- 9. NULL handling
SELECT COUNT(*) AS total_rows, COUNT(email) AS non_null_emails,
       COUNT(*) - COUNT(email) AS null_emails
FROM employees;
SELECT SUM(bonus) AS total_bonus, ROUND(AVG(bonus), 2) AS avg_bonus,
       COUNT(bonus) AS employees_with_bonus,
       ROUND(AVG(COALESCE(bonus, 0)), 2) AS avg_bonus_nulls_as_zero
FROM employees;

-- 10. Common patterns: many aggregates, conditional counts, percentages
SELECT department, COUNT(*) AS employee_count, MIN(salary) AS min_salary,
       MAX(salary) AS max_salary, ROUND(AVG(salary), 2) AS avg_salary,
       ROUND(STDDEV(salary), 2) AS salary_std_dev
FROM employees GROUP BY department ORDER BY avg_salary DESC;
SELECT department, COUNT(*) AS total_employees,
       COUNT(CASE WHEN salary > 50000 THEN 1 END) AS high_earners,
       COUNT(CASE WHEN hire_date > '2023-01-01' THEN 1 END) AS recent_hires
FROM employees GROUP BY department ORDER BY department;
SELECT department, COUNT(*) AS dept_count,
       COUNT(*)::FLOAT / (SELECT COUNT(*) FROM employees) * 100 AS percentage
FROM employees GROUP BY department ORDER BY percentage DESC, department;
