#!/bin/bash
cd "$(dirname "$0")" || exit 1
psql -X -q -d postgres -c "DROP DATABASE IF EXISTS query_practice" >/dev/null 2>&1
psql -X -q -d postgres -c "CREATE DATABASE query_practice"
{
  echo '$ psql -d query_practice -a -f lab12_querying_data.sql'
  PAGER=cat psql -X -a -d query_practice -f lab12_querying_data.sql
} > output.txt 2>&1
echo "Done: lab-12/output.txt"
