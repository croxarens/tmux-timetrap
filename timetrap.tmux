#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmux bind-key T display-menu -T "Timetrap" -x C -y C \
  "A  Start tracking time" a "display-popup -t . -T '  Start Tracking Time  ' -x C -y C 'bash $CURRENT_DIR/scripts/select.sh'" \
  "S  Stop current tracking" s "display-popup -t . -T '  Stop Tracking Time  ' -x C -y C 'bash $CURRENT_DIR/scripts/stop.sh'" \
  "T  Show today's summary" t "display-popup -t . -T '  Today Time Summary  ' -x C -y C -w 90% -h 80% 'bash $CURRENT_DIR/scripts/today-summary.sh; printf \\\"\\nPress Enter to close...\\\"; read -r _'" \
  "" "" "" \
  "Esc  Cancel" Escape ""
