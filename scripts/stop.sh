#!/bin/bash

db_location="$HOME/.timetrap.db"

# Create a temporary file to store fzf output
tmpfilepathname='/tmp/timetrap_option.txt'
rm -f $tmpfilepathname
tmpfile=$(mktemp $tmpfilepathname)

query_entries="SELECT sheet || ' | ' || note FROM entries WHERE end IS NULL AND sheet NOT REGEXP '^_' GROUP BY note ORDER BY id DESC;"
list=$(sqlite3 -readonly $db_location "$query_entries")

# Prompt the user for input and use fzf for interactive filtering
$(printf '%s\n' "${list[@]}" | fzf --ansi --print-query > "$tmpfile")
option=$(tail -1 $tmpfile | xargs)
rm -f $tmpfile

stop_track() {
    command='timetrap'
    $command sheet $1
    $command out
}

# Check if the selected value is in the list
echo "$list" | while IFS= read -r item; do
    if [ "$option" == "$item" ]; then
        sheet=$(echo $option | cut -d '|' -f 1 | xargs)
        stop_track $sheet
        break
    fi
done

tmux display-popup -C  # Close the TMUX Popup 
