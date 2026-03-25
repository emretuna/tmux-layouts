#!/bin/sh
# scripts/resolve_layout.sh
# Shared helper: given a window index and session name, returns the layout
# the user configured for it (or empty string if none).
# Sourced by other scripts — not executed directly.
# POSIX-compatible.
#
# Priority (highest → lowest):
#   @tmux_layouts_window_<index>
#   @tmux_layouts_session_<name>
#   @tmux_layouts_default

resolve_layout() {
  win_index="$1"
  session_name="$2"
  layout=""

  # 1. Per-window-index
  layout=$(tmux show-option -gqv "@tmux_layouts_window_${win_index}" 2>/dev/null)
  if [ -n "$layout" ]; then
    echo "$layout"
    return
  fi

  # 2. Per-session-name (sanitise: replace non-alphanumeric chars with _)
  if [ -n "$session_name" ]; then
    safe=$(echo "$session_name" | tr -c 'a-zA-Z0-9' '_')
    layout=$(tmux show-option -gqv "@tmux_layouts_session_${safe}" 2>/dev/null)
    if [ -n "$layout" ]; then
      echo "$layout"
      return
    fi
  fi

  # 3. Global default
  layout=$(tmux show-option -gqv "@tmux_layouts_default" 2>/dev/null)
  if [ -n "$layout" ]; then
    echo "$layout"
    return
  fi

  echo ""
}