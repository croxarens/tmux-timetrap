#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tmux bind-key A display-popup -t . -x C -y C "bash $CURRENT_DIR/scripts/select.sh"

# TODO: List current SHEETS
# TODO: Start a new tracking
# TODO: Stop a tracking
#
# TODO: Display all trackings
