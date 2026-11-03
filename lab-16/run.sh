#!/bin/bash
cd "$(dirname "$0")" || exit 1
psql -X -q -d postgres -c "DROP DATABASE IF EXISTS tx_practice" >/dev/null 2>&1
psql -X -q -d postgres -c "CREATE DATABASE tx_practice"
{
  echo '$ psql -d tx_practice -a -f lab16_transactions.sql'
  PAGER=cat psql -X -a -d tx_practice -f lab16_transactions.sql
} > output.txt 2>&1
{
  echo '$ bash isolation_demo.sh'
  bash isolation_demo.sh
} > isolation_output.txt 2>&1
echo "Done: lab-16/output.txt and lab-16/isolation_output.txt"
