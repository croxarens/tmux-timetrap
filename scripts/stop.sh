#!/bin/bash

resolve_timetrap() {
    local candidate
    local rbenv_bin=""

    for candidate in "$HOME/.rbenv/bin" "$HOME/.rbenv/shims" "/opt/homebrew/bin" "/usr/local/bin"; do
        if [ -d "$candidate" ] && [[ ":$PATH:" != *":$candidate:"* ]]; then
            PATH="$candidate:$PATH"
        fi
    done

    if command -v timetrap >/dev/null 2>&1; then
        command -v timetrap
        return 0
    fi

    if command -v rbenv >/dev/null 2>&1; then
        rbenv_bin="$(command -v rbenv)"
    elif [ -x "$HOME/.rbenv/bin/rbenv" ]; then
        rbenv_bin="$HOME/.rbenv/bin/rbenv"
    fi

    if [ -n "$rbenv_bin" ]; then
        local rbenv_root
        local timetrap_path

        rbenv_root="$($rbenv_bin root 2>/dev/null)"
        if [ -n "$rbenv_root" ]; then
            [ -d "$rbenv_root/shims" ] && PATH="$rbenv_root/shims:$PATH"
            [ -d "$rbenv_root/bin" ] && PATH="$rbenv_root/bin:$PATH"
        fi

        timetrap_path="$($rbenv_bin which timetrap 2>/dev/null)"
        if [ -n "$timetrap_path" ] && [ -x "$timetrap_path" ]; then
            echo "$timetrap_path"
            return 0
        fi
    fi

    return 1
}

if ! TIMETRAP_CMD="$(resolve_timetrap)"; then
    echo "timetrap not found. Install it with rbenv and ensure shims are available." >&2
    exit 1
fi

db_location="$HOME/.timetrap.db"
if [ -f "$HOME/.timetrap.yml" ]; then
  db_location=$(cat "$HOME/.timetrap.yml" | grep database | cut -d ':' -f 2|tr -d "\" ")
fi

# Create a temporary file to store fzf output
tmpfilepathname='/tmp/timetrap_option.txt'
rm -f $tmpfilepathname
tmpfile=$(mktemp $tmpfilepathname)

query_entries="SELECT sheet || ' | ' || note FROM entries WHERE end IS NULL AND sheet NOT REGEXP '^_' GROUP BY note ORDER BY id DESC;"
list=$(sqlite3 -readonly $db_location "$query_entries")

# Prompt the user for input and use fzf for interactive filtering
printf '%s\n' "$list" | fzf --ansi --print-query > "$tmpfile"
option=$(tail -1 $tmpfile | xargs)
rm -f $tmpfile

stop_track() {
    "$TIMETRAP_CMD" sheet "$1"
    "$TIMETRAP_CMD" out
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
