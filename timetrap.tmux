#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tmux bind-key A display-popup -t . -T '  Start Tracking Time  ' -x C -y C "bash $CURRENT_DIR/scripts/select.sh"
tmux bind-key S display-popup -t . -T '  Stop Tracking Time  ' -x C -y C "bash $CURRENT_DIR/scripts/stop.sh"
