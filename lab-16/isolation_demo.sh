#!/bin/bash
# Two sessions at the same time. Session A reads twice; session B changes the data in between.
DB=tx_practice
run_level() {
  psql -X -q -d $DB -c "UPDATE accounts SET balance = 1000 WHERE account_id = 2"
  echo "=== Session A: $1 ==="
  ( PAGER=cat psql -X -a -d $DB <<SQL
BEGIN TRANSACTION ISOLATION LEVEL $1;
SELECT balance AS first_read FROM accounts WHERE account_id = 2;
SELECT pg_sleep(2);   -- session B updates the row during this pause
SELECT balance AS second_read FROM accounts WHERE account_id = 2;
COMMIT;
SQL
  ) > /tmp/iso_a.txt 2>&1 &
  sleep 1
  echo "=== Session B (runs during A's pause) ==="
  PAGER=cat psql -X -a -d $DB -c "UPDATE accounts SET balance = 1 WHERE account_id = 2"
  wait
  cat /tmp/iso_a.txt
  echo
}
run_level "READ COMMITTED"
run_level "REPEATABLE READ"
