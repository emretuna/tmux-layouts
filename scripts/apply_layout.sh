#!/bin/sh
# scripts/apply_layout.sh
# Called by after-split-window and pane-exited hooks.
# Re-applies the active layout for the current window.
# POSIX-compatible.

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$PLUGIN_DIR/scripts/resolve_layout.sh"
. "$PLUGIN_DIR/scripts/layout_engine.sh"

WINDOW=$(tmux display-message -p '#{window_id}')
WIN_INDEX=$(tmux display-message -p '#{window_index}')
SESSION_NAME=$(tmux display-message -p '#{session_name}')

LAYOUT=$(resolve_layout "$WIN_INDEX" "$SESSION_NAME")
[ -z "$LAYOUT" ] && exit 0
[ "$LAYOUT" = "none" ] && exit 0

apply_layout "$LAYOUT" "$WINDOW"

# For spiral layout, save the newest pane (currently focused after split)
if [ "$LAYOUT" = "spiral" ]; then
  NEW_PANE=$(tmux display-message -p '#{pane_id}')
  tmux set-option -w -t "$WINDOW" "@tmux_layouts_spiral_last" "$NEW_PANE" 2>/dev/null
fi