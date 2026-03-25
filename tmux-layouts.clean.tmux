#!/usr/bin/env bash
# tmux-layouts.clean.tmux
# Run this script before uninstalling the plugin to remove hooks and keybindings.
# Usage: tmux run '~/.tmux/plugins/tmux-layouts/tmux-layouts.clean.tmux'
#
# Note: If you have other plugins that added hooks to the same events,
# those hooks will also be removed. Restart tmux or re-source your config
# after running this script to restore other plugins' hooks.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Remove our keybinding (if it's bound to our plugin)
NEW_PANE_KEY=$(tmux show-option -gqv "@tmux_layouts_new_pane_key" 2>/dev/null)
[[ -z "$NEW_PANE_KEY" ]] && NEW_PANE_KEY="n"

existing_binding=$(tmux list-keys -n "$NEW_PANE_KEY" 2>/dev/null)
if [[ "$existing_binding" == *"$PLUGIN_DIR"* ]]; then
  tmux unbind-key "$NEW_PANE_KEY" 2>/dev/null
fi

# Clear all layout window options
while IFS=: read -r session_name window_id; do
  WIN_KEY="@tmux_layout_${window_id}"
  tmux set-option -w -u -t "$window_id" "$WIN_KEY" 2>/dev/null
done < <(tmux list-windows -a -F '#{session_name}:#{window_id}' 2>/dev/null)

# Clear global options
tmux set-option -gu "@tmux_layouts_default" 2>/dev/null

# Remove hooks
# Note: This clears ALL hooks for these events, including from other plugins.
# Restart tmux or re-source config to restore other plugins' hooks.
tmux set-hook -gu after-split-window 2>/dev/null
tmux set-hook -gu pane-exited 2>/dev/null
tmux set-hook -gu after-new-window 2>/dev/null