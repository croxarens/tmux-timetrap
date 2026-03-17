#!/bin/bash

db_location="$HOME/.timetrap.db"
if [ -f "$HOME/.timetrap.yml" ]; then
  db_location=$(cat "$HOME/.timetrap.yml" | grep database | cut -d ':' -f 2 | tr -d "\" ")
fi

if [ ! -f "$db_location" ]; then
  echo "Timetrap database not found: $db_location"
  exit 0
fi

format_duration() {
    local total_seconds="$1"
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))
    printf "%02d:%02d:%02d" "$hours" "$minutes" "$seconds"
}

print_rule() {
    local width="$1"
    printf '%*s' "$width" '' | tr ' ' '-'
}

query=$(cat <<'SQL'
WITH bounds AS (
  SELECT
    datetime('now', 'localtime', 'start of day') AS day_start,
    datetime('now', 'localtime') AS now_local
),
raw_overlaps AS (
  SELECT
    e.sheet,
    e.note,
    CASE
      WHEN datetime(e.start) > b.day_start THEN datetime(e.start)
      ELSE b.day_start
    END AS effective_start,
    CASE
      WHEN datetime(COALESCE(e.end, b.now_local)) < b.now_local THEN datetime(COALESCE(e.end, b.now_local))
      ELSE b.now_local
    END AS effective_end
  FROM entries e
  CROSS JOIN bounds b
  WHERE datetime(e.start) < b.now_local
    AND datetime(COALESCE(e.end, b.now_local)) > b.day_start
    AND e.sheet NOT LIKE '\_%' ESCAPE '\'
),
note_totals AS (
  SELECT
    sheet,
    note,
    SUM(
      CAST((julianday(effective_end) - julianday(effective_start)) * 86400 AS INTEGER)
    ) AS seconds
  FROM raw_overlaps
  WHERE effective_end > effective_start
  GROUP BY sheet, note
),
sheet_totals AS (
  SELECT
    sheet,
    SUM(seconds) AS seconds
  FROM note_totals
  GROUP BY sheet
),
grand_total AS (
  SELECT SUM(seconds) AS seconds FROM sheet_totals
)
SELECT 0 AS ord, sheet AS ord_sheet, note AS ord_note, 'note' AS row_type, sheet, note, seconds FROM note_totals
UNION ALL
SELECT 1 AS ord, sheet AS ord_sheet, '' AS ord_note, 'sheet_total' AS row_type, sheet, 'TOTAL' AS note, seconds FROM sheet_totals
UNION ALL
SELECT 2 AS ord, '' AS ord_sheet, '' AS ord_note, 'grand_total' AS row_type, 'ALL SHEETS' AS sheet, 'TOTAL' AS note, seconds
FROM grand_total
WHERE (SELECT COUNT(*) FROM sheet_totals) > 1
ORDER BY ord, ord_sheet, ord_note;
SQL
)

rows=$(sqlite3 -readonly -separator $'\x1f' "$db_location" "$query")

if [ -z "$rows" ]; then
  echo "No tracked time for today."
  exit 0
fi

sheet_width=5
note_width=4
time_width=4

declare -a output_rows

while IFS=$'\x1f' read -r _ _ _ row_type sheet note seconds; do
  [ -z "$sheet" ] && continue

  if [ "$row_type" = "sheet_total" ]; then
    note="TOTAL"
  elif [ "$row_type" = "grand_total" ]; then
    note="TOTAL"
  fi

  duration="$(format_duration "$seconds")"
  output_rows+=("$sheet"$'\t'"$note"$'\t'"$duration")

  [ "${#sheet}" -gt "$sheet_width" ] && sheet_width="${#sheet}"
  [ "${#note}" -gt "$note_width" ] && note_width="${#note}"
  [ "${#duration}" -gt "$time_width" ] && time_width="${#duration}"
done <<< "$rows"

printf "%-${sheet_width}s  %-${note_width}s  %${time_width}s\n" "SHEET" "NOTE" "TIME"
print_rule "$sheet_width"
printf "  "
print_rule "$note_width"
printf "  "
print_rule "$time_width"
printf "\n"

for row in "${output_rows[@]}"; do
  IFS=$'\t' read -r sheet note duration <<< "$row"
  printf "%-${sheet_width}s  %-${note_width}s  %${time_width}s\n" "$sheet" "$note" "$duration"
done
