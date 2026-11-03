-- Lab 16: Transactions and ACID Properties
-- Nurofarid Kukanbekova · AUCA · Databases
-- Run in a fresh database: tx_practice

-- 1. Sample data (CHECK constraints make some operations fail on purpose)
CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    owner VARCHAR(50),
    balance DECIMAL(10,2) CHECK (balance >= 0)
);
CREATE TABLE customers (customer_id SERIAL PRIMARY KEY, name VARCHAR(50), email VARCHAR(50));
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    total DECIMAL(10,2)
);
CREATE TABLE inventory (product_id INT PRIMARY KEY, stock INT CHECK (stock >= 0));
CREATE TABLE order_items (order_id INT REFERENCES orders(order_id), product_id INT REFERENCES inventory(product_id), quantity INT);
CREATE TABLE products (id SERIAL PRIMARY KEY, name VARCHAR(50), price DECIMAL(8,2) CHECK (price > 0));
CREATE TABLE logs (id SERIAL PRIMARY KEY, message TEXT);
INSERT INTO accounts (owner, balance) VALUES ('Aida', 1000.00), ('Timur', 200.00);
INSERT INTO customers (name, email) VALUES ('Meerim Bekova', 'meerim@mail.kg');
INSERT INTO inventory VALUES (101, 10), (102, 3);
SELECT * FROM accounts ORDER BY account_id;

-- 2. BEGIN + COMMIT saves, BEGIN + ROLLBACK undoes
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;
SELECT * FROM accounts ORDER BY account_id;
START TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
SELECT * FROM accounts ORDER BY account_id;   -- changed inside the transaction
ROLLBACK;
SELECT * FROM accounts ORDER BY account_id;   -- back to 900 / 300

-- 3. A full transfer of 500: check the balance first, then move the money
BEGIN TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 1;
UPDATE accounts SET balance = balance - 500 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 500 WHERE account_id = 2;
COMMIT;
SELECT * FROM accounts ORDER BY account_id;

-- 4. ATOMICITY: one failing statement cancels the whole transaction
BEGIN;
UPDATE accounts SET balance = balance + 1000 WHERE account_id = 2;   -- this one works...
-- EXPECTED ERROR: account 1 has only 400, so balance would go below 0 (CHECK)
UPDATE accounts SET balance = balance - 1000 WHERE account_id = 1;
-- EXPECTED ERROR: after an error PostgreSQL ignores everything until ROLLBACK
SELECT * FROM accounts;
ROLLBACK;
SELECT * FROM accounts ORDER BY account_id;   -- Timur did NOT get the 1000

-- 5. CONSISTENCY: constraints keep the data valid
BEGIN;
INSERT INTO customers (name, email) VALUES ('John Doe', 'john@email.com');
INSERT INTO orders (customer_id, total) VALUES (currval('customers_customer_id_seq'), 100.00);
COMMIT;
SELECT c.name, o.order_id, o.total FROM orders o JOIN customers c USING (customer_id);
-- EXPECTED ERROR: customer 99 does not exist, so the foreign key refuses the order
INSERT INTO orders (customer_id, total) VALUES (99, 50.00);

-- 6. Isolation levels (one session; the two-session demo is in isolation_output.txt)
SHOW transaction_isolation;   -- the default
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SHOW transaction_isolation;   -- accepted, but PostgreSQL never does dirty reads
COMMIT;
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SHOW transaction_isolation;
COMMIT;
BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SHOW transaction_isolation;
COMMIT;

-- 7. SERIALIZABLE transaction: 5% interest for every account
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM accounts ORDER BY account_id;
UPDATE accounts SET balance = balance * 1.05;
SELECT * FROM accounts ORDER BY account_id;
COMMIT;

-- 8. SAVEPOINT: undo only part of a transaction
BEGIN;
INSERT INTO customers (name, email) VALUES ('Alice', 'alice@email.com');
SAVEPOINT after_customer_insert;
INSERT INTO orders (customer_id, total) VALUES (1, 500.00);
ROLLBACK TO SAVEPOINT after_customer_insert;
INSERT INTO orders (customer_id, total) VALUES (1, 300.00);
COMMIT;
SELECT order_id, customer_id, total FROM orders ORDER BY order_id;

-- 9. Several savepoints, and RELEASE SAVEPOINT
BEGIN;
INSERT INTO products (name, price) VALUES ('Laptop', 999.99);
SAVEPOINT sp1;
INSERT INTO products (name, price) VALUES ('Mouse', 25.99);
SAVEPOINT sp2;
-- EXPECTED ERROR: price must be > 0 (CHECK)
INSERT INTO products (name, price) VALUES ('Invalid Product', -50.00);
ROLLBACK TO SAVEPOINT sp2;   -- the transaction is usable again
INSERT INTO products (name, price) VALUES ('Keyboard', 79.99);
COMMIT;
SELECT * FROM products ORDER BY id;
BEGIN;
INSERT INTO logs (message) VALUES ('Starting process');
SAVEPOINT process_start;
INSERT INTO logs (message) VALUES ('Process completed');
RELEASE SAVEPOINT process_start;
COMMIT;

-- 10. Handling errors in a DO block
-- Aida's account has less than 5000, so the block refuses the transfer
DO $$
DECLARE
    current_balance DECIMAL;
BEGIN
    SELECT balance INTO current_balance FROM accounts WHERE account_id = 1;
    IF current_balance < 5000 THEN
        RAISE NOTICE 'Transaction failed: insufficient funds (balance %)', current_balance;
        RETURN;
    END IF;
    UPDATE accounts SET balance = balance - 5000 WHERE account_id = 1;
    UPDATE accounts SET balance = balance + 5000 WHERE account_id = 2;
END $$;
-- EXPECTED ERROR: the handout's version calls ROLLBACK inside the block while BEGIN is open
BEGIN;
DO $$
BEGIN
    RAISE NOTICE 'Transaction failed: Insufficient funds';
    ROLLBACK;
END $$;
ROLLBACK;

-- 11. Best practices: short transactions, savepoints for items, locks
BEGIN;
UPDATE inventory SET stock = stock - 1 WHERE product_id = 101;
INSERT INTO order_items (order_id, product_id, quantity) VALUES (1, 101, 1);
COMMIT;
BEGIN;
INSERT INTO orders (customer_id, total) VALUES (1, 1000.00);
SAVEPOINT before_items;
INSERT INTO order_items VALUES (currval('orders_order_id_seq'), 101, 2);
INSERT INTO order_items VALUES (currval('orders_order_id_seq'), 102, 1);
COMMIT;
SELECT * FROM order_items ORDER BY order_id, product_id;
-- blocked transactions right now (none, so 0 rows)
SELECT blocked_locks.pid AS blocked_pid, blocking_locks.pid AS blocking_pid,
       blocked_activity.query AS blocked_statement
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
WHERE NOT blocked_locks.granted;

-- 12. DURABILITY: reconnect and the committed data is still there
\c tx_practice
SELECT * FROM accounts ORDER BY account_id;
SELECT count(*) AS products_saved FROM products;
SELECT * FROM logs;
