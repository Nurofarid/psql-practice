-- Lab 14: Joining Tables
-- Nurofarid Kukanbekova · AUCA · Databases
-- Run in a fresh database: join_practice

-- 1. Tables for a small shop (customers, orders, products, order_items)
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),   -- NULL allowed: guest order
    order_date DATE,
    total_amount DECIMAL(10,2)
);
CREATE TABLE products (product_id SERIAL PRIMARY KEY, product_name VARCHAR(50), price DECIMAL(8,2));
CREATE TABLE order_items (
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER,
    PRIMARY KEY (order_id, product_id)
);

-- 2. Sample data (Bakyt has no orders, order 5 has no customer)
INSERT INTO customers (name, email) VALUES
    ('Aida Karimova', 'aida@mail.kg'), ('Timur Bekov', 'timur@mail.kg'),
    ('Meerim Bekova', 'meerim@mail.kg'), ('Bakyt Mamatov', 'bakyt@mail.kg');   -- Bakyt never orders
INSERT INTO orders (customer_id, order_date, total_amount) VALUES
    (1, '2023-12-20', 80.00), (1, '2024-03-05', 250.00), (2, '2024-05-11', 45.00),
    (3, '2024-07-01', 180.00), (NULL, '2024-08-15', 60.00);                  -- order 5: guest
INSERT INTO products (product_name, price) VALUES ('Notebook', 5.00), ('Pen', 2.00), ('Backpack', 40.00);
INSERT INTO order_items VALUES (1, 1, 10), (1, 2, 15), (2, 3, 5), (2, 1, 10), (3, 3, 1), (4, 3, 4), (5, 2, 30);
SELECT * FROM customers;
SELECT * FROM orders;

-- 3. INNER JOIN (only matches) and LEFT JOIN (all customers)
SELECT c.name, c.email, o.order_date, o.total_amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;
SELECT c.name, c.email, o.order_date, o.total_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- 4. RIGHT JOIN (all orders) and FULL OUTER JOIN (everything)
SELECT c.name, c.email, o.order_date, o.total_amount
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;
SELECT c.name, c.email, o.order_date, o.total_amount
FROM customers c
FULL OUTER JOIN orders o ON c.customer_id = o.customer_id;

-- 5. CROSS JOIN: every customer with every product (4 x 3 = 12 rows)
SELECT c.name, p.product_name
FROM customers c
CROSS JOIN products p;

-- 6. Joining four tables, and a join with extra conditions
SELECT c.name, o.order_date, oi.quantity, p.product_name, p.price
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id, p.product_name;
SELECT c.name, o.order_date, o.total_amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date >= '2024-01-01'
  AND o.total_amount > 100;

-- 7. Self join: employees and their managers
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    manager_id INTEGER REFERENCES employees(employee_id)
);
INSERT INTO employees (name, manager_id) VALUES
    ('Aibek Sharshenov', NULL), ('Ainura Toktomamatova', 1), ('Brandon Lee', 1),
    ('Gulzat Sultanova', 2), ('Tilek Usubaliev', 2);
SELECT e1.name AS employee, e2.name AS manager
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.employee_id
ORDER BY e1.employee_id;

-- 8. One-to-one and one-to-many
CREATE TABLE users (user_id SERIAL PRIMARY KEY, username VARCHAR(30));
CREATE TABLE user_profiles (
    user_id INTEGER PRIMARY KEY REFERENCES users(user_id),
    first_name VARCHAR(30), last_name VARCHAR(30), phone VARCHAR(15)
);
INSERT INTO users (username) VALUES ('nuri'), ('timur_b'), ('newbie');
INSERT INTO user_profiles VALUES (1, 'Nurofarid', 'Kukanbekova', '0555-000-111'), (2, 'Timur', 'Bekov', NULL);
SELECT u.username, up.first_name, up.last_name, up.phone
FROM users u
LEFT JOIN user_profiles up ON u.user_id = up.user_id;
CREATE TABLE authors (author_id SERIAL PRIMARY KEY, author_name VARCHAR(50));
CREATE TABLE books (book_id SERIAL PRIMARY KEY, title VARCHAR(100), publication_year INT,
                    author_id INTEGER REFERENCES authors(author_id));
INSERT INTO authors (author_name) VALUES ('Chingiz Aitmatov'), ('Abraham Silberschatz'), ('New Writer');
INSERT INTO books (title, publication_year, author_id) VALUES
    ('The White Ship', 1970, 1), ('Jamilia', 1958, 1), ('The Day Lasts More than a Hundred Years', 1980, 1),
    ('Database System Concepts', 2019, 2), ('Operating System Concepts', 2018, 2);
SELECT a.author_name, b.title, b.publication_year
FROM authors a
INNER JOIN books b ON a.author_id = b.author_id
ORDER BY a.author_name, b.publication_year;

-- 9. Many-to-many: through the junction table enrollments
CREATE TABLE students (student_id SERIAL PRIMARY KEY, student_name VARCHAR(50));
CREATE TABLE courses (course_id SERIAL PRIMARY KEY, course_name VARCHAR(50));
CREATE TABLE enrollments (
    student_id INTEGER REFERENCES students(student_id),
    course_id INTEGER REFERENCES courses(course_id),
    enrollment_date DATE, grade CHAR(2),
    PRIMARY KEY (student_id, course_id)
);
INSERT INTO students (student_name) VALUES ('Alymbek'), ('Beka'), ('Nuri');
INSERT INTO courses (course_name) VALUES ('Databases'), ('Statistics'), ('Calculus');
INSERT INTO enrollments VALUES
    (1, 1, '2026-09-01', 'A'), (1, 2, '2026-09-01', 'B+'), (2, 1, '2026-09-02', 'A-'),
    (3, 1, '2026-09-01', 'A'), (3, 3, '2026-09-03', NULL);
SELECT s.student_name, c.course_name, e.enrollment_date, e.grade
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN courses c ON e.course_id = c.course_id
WHERE e.grade IS NOT NULL
ORDER BY s.student_name, c.course_name;

-- 10. Indexes on join columns and common pitfalls
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
-- wrong: no join condition gives a Cartesian product (4 customers x 5 orders)
SELECT COUNT(*) AS cartesian_rows FROM customers c, orders o;
-- correct: with the join condition
SELECT COUNT(*) AS joined_rows FROM customers c INNER JOIN orders o ON c.customer_id = o.customer_id;
-- customers without orders: LEFT JOIN + IS NULL
SELECT c.name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;
-- EXPECTED ERROR: customer_id exists in both tables, so it must be prefixed (c. or o.)
SELECT customer_id, order_date
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;
