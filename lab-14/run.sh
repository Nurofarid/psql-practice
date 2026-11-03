#!/bin/bash
cd "$(dirname "$0")" || exit 1
psql -X -q -d postgres -c "DROP DATABASE IF EXISTS join_practice" >/dev/null 2>&1
psql -X -q -d postgres -c "CREATE DATABASE join_practice"
{
  echo '$ psql -d join_practice -a -f lab14_joining_tables.sql'
  PAGER=cat psql -X -a -d join_practice -f lab14_joining_tables.sql
} > output.txt 2>&1
echo "Done: lab-14/output.txt"
