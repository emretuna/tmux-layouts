#!/bin/sh
# scripts/new_pane.sh
# Bound to @tmux_layouts_new_pane_key (default: prefix + n).
# Opens a new pane in the direction that matches the active layout.
# POSIX-compatible.

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$PLUGIN_DIR/scripts/resolve_layout.sh"

WINDOW=$(tmux display-message -p '#{window_id}')
WIN_INDEX=$(tmux display-message -p '#{window_index}')
SESSION_NAME=$(tmux display-message -p '#{session_name}')
LAYOUT=$(resolve_layout "$WIN_INDEX" "$SESSION_NAME")

case "$LAYOUT" in
  vstack)
    # Main pane top, horizontal stack below (side-by-side)
    tmux split-window -h -c "#{pane_current_path}"
    ;;

  hstack)
    # Main pane left, vertical stack on right (stacked)
    tmux split-window -v -c "#{pane_current_path}"
    ;;

  spiral)
    # Each new pane splits the previous one, alternating h/v
    LAST_PANE=$(tmux show-option -wqv "@tmux_layouts_spiral_last" 2>/dev/null)

    # If no last pane stored or pane doesn't exist, use current pane
    if [ -z "$LAST_PANE" ]; then
      LAST_PANE=$(tmux display-message -p '#{pane_id}')
    else
      if ! tmux list-panes -t "$WINDOW" -F '#{pane_id}' 2>/dev/null | grep -q "^${LAST_PANE}$"; then
        LAST_PANE=$(tmux display-message -p '#{pane_id}')
      fi
    fi

    pane_count=$(tmux list-panes -t "$WINDOW" -F '#{pane_id}' 2>/dev/null | wc -l | tr -d ' ')

    if [ $((pane_count % 2)) -eq 1 ]; then
      tmux split-window -h -t "$LAST_PANE" -c "#{pane_current_path}"
    else
      tmux split-window -v -t "$LAST_PANE" -c "#{pane_current_path}"
    fi
    ;;

  *)
    tmux split-window -v -c "#{pane_current_path}"
    ;;
esac