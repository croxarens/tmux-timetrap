#!/bin/bash

db_location="$HOME/.timetrap.db"

# Create a temporary file to store fzf output
tmpfilepathname='/tmp/timetrap_option.txt'
rm $tmpfilepathname
tmpfile=$(mktemp $tmpfilepathname)

# Get the list of past entries per each sheet in the last 40 days.
#
# Ignore the achived sheets
# AND sheet NOT REGEXP '^_'
query_entries="SELECT sheet || ' | ' || note FROM entries WHERE start >= date('now', '-40 days') AND sheet NOT REGEXP '^_' GROUP BY note"
list=$(sqlite3 -readonly $db_location "$query_entries")

# Prompt the user for input and use fzf for interactive filtering
$(printf '%s\n' "${list[@]}" | fzf --ansi --print-query > "$tmpfile")
option=$(tail -1 $tmpfile | xargs)
rm $tmpfile

update_track() {
    command='timetrap'
    $command sheet $1  # Update Sheet
    $command in "$2"  # Start timer with new Note
}

# Check if the selected value is in the list
echo "$list" | while IFS= read -r item; do
    if [ "$option" == "$item" ]; then
        sheet=$(echo $option | cut -d '|' -f 1 | xargs)
        note=$(echo $option | cut -d '|' -f 2 | xargs)
        update_track $sheet "$note"
        break
    fi
done

sheet=$(echo $option | cut -d '.' -f 1 | xargs)
note=$(echo $option | cut -d '.' -f 2 | xargs)
update_track $sheet "$note"


#tmux display-popup -C  # Close the TMUX Popup 
