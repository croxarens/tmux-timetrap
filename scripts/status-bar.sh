#!/bin/bash

TIMETRAP_STR="$(timetrap now)"

SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
IFS=$'\n'      # Change IFS to newline char
records=($TIMETRAP_STR) # split the `records` string into an array by the same name
IFS=$SAVEIFS   # Restore original IFS

MSG=''

for (( i=0; i<${#records[@]}; i++ ))
do
    NOTE="$(echo ${records[$i]} | cut -d '(' -f2 | cut -d ')' -f1)"
    SHEET="$(echo ${records[$i]} | cut -d ':' -f1)"
    MSG="$MSG[$SHEET] $NOTE | "
done

echo "$MSG"

