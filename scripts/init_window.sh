#!/bin/sh
# scripts/init_window.sh
# Called by the after-new-window hook.
# Applies the configured layout to the new window.
# POSIX-compatible.

if [ -n "$1" ]; then
  PLUGIN_DIR="$1"
else
  PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
fi

. "$PLUGIN_DIR/scripts/resolve_layout.sh"
. "$PLUGIN_DIR/scripts/layout_engine.sh"

WINDOW=$(tmux display-message -p '#{window_id}')
WIN_INDEX=$(tmux display-message -p '#{window_index}')
SESSION_NAME=$(tmux display-message -p '#{session_name}')

layout=$(resolve_layout "$WIN_INDEX" "$SESSION_NAME")
[ -z "$layout" ] && exit 0
[ "$layout" = "none" ] && exit 0

apply_layout "$layout" "$WINDOW"