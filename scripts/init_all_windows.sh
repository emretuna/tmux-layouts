#!/bin/sh
# scripts/init_all_windows.sh
# Runs once when the plugin loads (tmux source / TPM install).
# Applies the configured layout to all existing windows.
# POSIX-compatible.

if [ -n "$1" ]; then
  PLUGIN_DIR="$1"
else
  PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
fi

. "$PLUGIN_DIR/scripts/resolve_layout.sh"
. "$PLUGIN_DIR/scripts/layout_engine.sh"

tmux list-windows -a -F '#{session_name}:#{window_id}:#{window_index}' 2>/dev/null | while IFS=: read -r session_name window_id win_index; do
  layout=$(resolve_layout "$win_index" "$session_name")
  if [ -n "$layout" ] && [ "$layout" != "none" ]; then
    apply_layout "$layout" "$window_id"
  fi
done