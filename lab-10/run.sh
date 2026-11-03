#!/bin/bash
cd "$(dirname "$0")" || exit 1
# Lab 10 reads the database built in Lab 09; build it if it is missing
if ! psql -X -q -d design_practice -c "SELECT 1 FROM loans LIMIT 1" >/dev/null 2>&1; then
  bash ../lab-09/run.sh
fi
{
  echo '$ psql -d design_practice -a -f lab10_viewing_structure.sql'
  PAGER=cat psql -X -a -d design_practice -f lab10_viewing_structure.sql
} > output.txt 2>&1
echo "Done: lab-10/output.txt"
