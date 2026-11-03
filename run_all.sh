#!/bin/bash
# Runs every lab in order and checks that each output has exactly the expected number of errors.
cd "$(dirname "$0")" || exit 1

if ! psql -X -q -d postgres -c "SELECT 1" >/dev/null 2>&1; then
  echo "PostgreSQL is not running. Start it with:  brew services start postgresql@18"
  exit 1
fi

# lab number : expected errors
expected="03:0 04:0 05:3 06:6 07:5 08:7 09:2 10:0 11:1 12:1 13:2 14:1 15:2 16:5 17:1"

ok=0; bad=0
for item in $expected; do
  lab="lab-${item%%:*}"; want="${item##*:}"
  bash "$lab/run.sh" >/dev/null 2>&1
  got=$(grep -c "^psql.*ERROR" "$lab/output.txt")
  if [ "$got" = "$want" ]; then
    echo "OK     $lab  ($got expected error(s))"; ok=$((ok+1))
  else
    echo "CHECK  $lab  -> $got error(s), expected $want. Look at $lab/output.txt"; bad=$((bad+1))
  fi
done
echo "----"
echo "$ok labs OK, $bad to check"
