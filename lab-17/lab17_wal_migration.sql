-- Lab 17 part 3: WAL, restore points, replication and ETL migration
-- Runs in shop_db after the backup steps

-- 10. WAL settings, restore point, WAL switch
SHOW wal_level;
SHOW archive_mode;
SELECT pg_create_restore_point('before_data_migration') IS NOT NULL AS restore_point_created;
SELECT pg_current_wal_lsn() IS NOT NULL AS wal_position_known;
SELECT pg_switch_wal() IS NOT NULL AS wal_switched;

-- 11. Logical replication: a publication (the subscription would be on another server)
CREATE PUBLICATION migration_pub FOR ALL TABLES;
SELECT pubname, puballtables FROM pg_publication;
DROP PUBLICATION migration_pub;

-- 12. ETL migration: staging table, batch export/import, merge with ON CONFLICT
CREATE TABLE target_customers (customer_id INT PRIMARY KEY, name VARCHAR(30), city VARCHAR(30));
INSERT INTO target_customers VALUES (1, 'Aida', 'Osh'), (2, 'Timur', 'Bishkek');
CREATE TABLE customers (customer_id INT PRIMARY KEY, name VARCHAR(30), city VARCHAR(30));
INSERT INTO customers VALUES (1, 'Aida', 'Bishkek'), (2, 'Timur', 'Bishkek'), (3, 'Meerim', 'Naryn');
CREATE TABLE staging_customers AS SELECT * FROM customers WHERE 1=0;
\copy (SELECT * FROM customers ORDER BY customer_id LIMIT 10000 OFFSET 0) TO 'files/customers_batch_1.csv' WITH CSV HEADER
\copy staging_customers FROM 'files/customers_batch_1.csv' WITH CSV HEADER
SELECT count(*) AS source_rows FROM customers;
INSERT INTO target_customers
SELECT * FROM staging_customers
ON CONFLICT (customer_id) DO UPDATE SET name = EXCLUDED.name, city = EXCLUDED.city;
SELECT * FROM target_customers ORDER BY customer_id;
SELECT count(*) AS target_rows FROM target_customers;

-- 13. Partitioning a large table so it can be migrated piece by piece
CREATE TABLE large_table (id INT, created DATE, amount NUMERIC) PARTITION BY RANGE (created);
CREATE TABLE large_table_2025 PARTITION OF large_table FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE large_table_2026 PARTITION OF large_table FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
INSERT INTO large_table SELECT g, DATE '2025-01-01' + g, g * 10 FROM generate_series(1, 600) g;
SELECT tableoid::regclass AS partition, count(*) FROM large_table GROUP BY 1 ORDER BY 1;
