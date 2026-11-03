#!/bin/bash
cd "$(dirname "$0")" || exit 1
psql -X -q -d postgres -c "DROP DATABASE IF EXISTS data_ops" >/dev/null 2>&1
psql -X -q -d postgres -c "CREATE DATABASE data_ops"
{
  echo '$ psql -d data_ops -a -f lab11_data_operations.sql'
  PAGER=cat psql -X -a -d data_ops -f lab11_data_operations.sql
} > output.txt 2>&1
echo "Done: lab-11/output.txt"
