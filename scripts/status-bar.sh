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
    exit 0
fi

TIMETRAP_STR="$("$TIMETRAP_CMD" now 2>/dev/null)"

SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
IFS=$'\n'      # Change IFS to newline char
records=($TIMETRAP_STR) # split the `records` string into an array by the same name
IFS=$SAVEIFS   # Restore original IFS

MSG=''

for (( i=0; i<${#records[@]}; i++ ))
do
    NOTE="$(echo "${records[$i]}" | cut -d '(' -f2 | cut -d ')' -f1)"
    SHEET="$(echo "${records[$i]}" | cut -d ':' -f1)"
    if [ -n "$MSG" ]; then
        MSG="${MSG} | "
    fi
    MSG="${MSG}[${SHEET}] ${NOTE}"
done

echo "$MSG"
