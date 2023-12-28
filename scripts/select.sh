#!/bin/bash

db_location="$HOME/.timetrap.db"
if [ -f "$HOME/.timetrap.yml" ]; then
  db_location=$(cat "$HOME/.timetrap.yml" | grep database | cut -d ':' -f 2|tr -d "\" ")
fi

# Create a temporary file to store fzf output
tmpfilepathname='/tmp/timetrap_option.txt'
rm -f $tmpfilepathname
tmpfile=$(mktemp $tmpfilepathname)

# Get the list of past entries per each sheet in the last 40 days.
#
# Ignore the achived sheets
# AND sheet NOT REGEXP '^_'
query_entries="SELECT sheet || ' | ' || note FROM entries WHERE start >= date('now', '-40 days') AND sheet NOT REGEXP '^_' GROUP BY sheet, note ORDER BY id DESC;"
list=$(sqlite3 -readonly $db_location "$query_entries")

# Prompt the user for input and use fzf for interactive filtering
$(printf '%s\n' "${list[@]}" | fzf --ansi --print-query > "$tmpfile")
option=$(tail -1 $tmpfile | xargs)
rm -f $tmpfile

update_track() {
    command='timetrap'
    $command sheet $1   # Update Sheet
    $command out        # In case the sheet is alredy tracking something else
    $command in "$2"    # Start timer with new Note
}

# Check if the selected value is in the list
echo "$list" | while IFS= read -r item; do
    if [ "$option" == "$item" ]; then
        sheet=$(echo $option | cut -d '|' -f 1 | xargs)
        note=$(echo $option | cut -d '|' -f 2 | xargs)
        update_track $sheet "$note"
        tmux display-popup -C  # Close the TMUX Popup 
        break
    fi
done

sheet=$(echo $option | cut -d '.' -f 1 | xargs)
note=$(echo $option | cut -d '.' -f 2 | xargs)
update_track $sheet "$note"

tmux display-popup -C  # Close the TMUX Popup 
