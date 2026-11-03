#!/bin/bash
cd "$(dirname "$0")" || exit 1
psql -X -q -d postgres -c "DROP DATABASE IF EXISTS advanced_practice" >/dev/null 2>&1
psql -X -q -d postgres -c "CREATE DATABASE advanced_practice"
{
  echo '$ psql -d advanced_practice -a -f lab15_advanced_querying.sql'
  PAGER=cat psql -X -a -d advanced_practice -f lab15_advanced_querying.sql
} > output.txt 2>&1
echo "Done: lab-15/output.txt"
