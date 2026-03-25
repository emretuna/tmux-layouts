#!/bin/sh
# scripts/pane_exited.sh
# Called by pane-exited hook.
# Selects the lowest indexed pane after a pane closes, then re-applies layout.
# POSIX-compatible.

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Check if feature is enabled (default: true)
ENABLED=$(tmux show-option -gqv "@tmux_layouts_select_lower_on_close" 2>/dev/null)
[ -z "$ENABLED" ] && ENABLED="true"

WINDOW=$(tmux display-message -p '#{window_id}')

# Select the pane with the lowest index among remaining panes
if [ "$ENABLED" = "true" ]; then
  LOWEST=$(tmux list-panes -t "$WINDOW" -F '#{pane_index}' 2>/dev/null | sort -n | head -1)
  if [ -n "$LOWEST" ]; then
    tmux select-pane -t "$WINDOW.$LOWEST"
  fi
fi

# Re-apply layout if configured
. "$PLUGIN_DIR/scripts/resolve_layout.sh"
. "$PLUGIN_DIR/scripts/layout_engine.sh"

WIN_INDEX=$(tmux display-message -p '#{window_index}')
SESSION_NAME=$(tmux display-message -p '#{session_name}')
LAYOUT=$(resolve_layout "$WIN_INDEX" "$SESSION_NAME")

[ -n "$LAYOUT" ] && [ "$LAYOUT" != "none" ] && apply_layout "$LAYOUT" "$WINDOW"