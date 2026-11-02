#!/bin/bash
# Shows each part of output.txt in this Terminal window and captures the window to the Desktop.
cd "$(dirname "$0")" || exit 1
WIN=$(osascript -e 'tell application "Terminal" to id of front window')
shot() {  # shot <name> <sed range>
  clear
  sed -n "$2p" output.txt
  sleep 1
  screencapture -x -o -l "$WIN" ~/Desktop/lab08_"$1".png
}
shot 01_methods_integrity '/^-- Method 4/,/^-- 3\./'
shot 02_cascade           '/^-- 3\./,/^-- 4\./'
shot 03_set_null          '/^-- 4\./,/^-- 5\./'
shot 04_set_default       '/^-- 5\./,/^-- 6\./'
shot 05_restrict          '/^-- 6\./,/^-- 7\./'
shot 06_update_cascade    '/^-- 7\./,/^-- 8\./'
shot 07_one_to_one        '/^-- 8\./,/^-- Alternative/'
shot 08_one_to_many       '/^-- 9\./,/^-- 10\./'
shot 09_many_to_many      '/^-- All enrollments/,$'
clear
ls ~/Desktop/lab08_*.png
echo "Screenshots saved to the Desktop."
