#!/bin/sh
# tmux-layouts.tmux
# TPM entry point — loaded by `run '~/.tmux/plugins/tpm/tpm'`
# Repository: https://github.com/emretuna/tmux-layouts
# POSIX-compatible.

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"

# ─────────────────────────────────────────────────────────────────────────────
#  Hooks
#  after-split-window  → re-apply layout after a new pane is created
#  pane-exited         → re-apply layout after a pane is closed
#  after-new-window    → assign layout from config to each new window
#
#  We append (-a) to existing hooks instead of overwriting, but only if
#  our hook isn't already present (prevents duplicates on tmux source).
# ─────────────────────────────────────────────────────────────────────────────
add_hook_if_missing() {
  hook_name="$1"
  hook_cmd="$2"
  existing=$(tmux show-hook -g "$hook_name" 2>/dev/null | sed 's/^[^=]*=//')
  if [ -z "$existing" ] || ! echo "$existing" | grep -q "$PLUGIN_DIR"; then
    tmux set-hook -g -a "$hook_name" "$hook_cmd"
  fi
}

add_hook_if_missing after-split-window "run-shell '\"$PLUGIN_DIR/scripts/apply_layout.sh\"'"
add_hook_if_missing pane-exited        "run-shell '\"$PLUGIN_DIR/scripts/pane_exited.sh\"'"
add_hook_if_missing after-new-window   "run-shell '\"$PLUGIN_DIR/scripts/init_window.sh\" \"$PLUGIN_DIR\"'"

# ─────────────────────────────────────────────────────────────────────────────
#  New-pane keybinding
#
#  A single smart split that replaces tmux's separate % and " bindings.
#  It picks the correct split direction for the active layout automatically.
#
#  Configure in tmux.conf (before the TPM run line):
#
#    set -g @tmux_layouts_new_pane_key "n"    # default
#    set -g @tmux_layouts_new_pane_key "|"    # custom
#    set -g @tmux_layouts_new_pane_key ""     # disable; keep tmux defaults
#
#  Re-binds on every load; bind-key overwrites the prior binding, so
#  re-sourcing tmux.conf creates no duplicates. To use a different key,
#  set @tmux_layouts_new_pane_key (above); to keep tmux's default, set it to "".
# ─────────────────────────────────────────────────────────────────────────────
NEW_PANE_KEY=$(tmux show-option -gqv "@tmux_layouts_new_pane_key" 2>/dev/null)
# If the option is not set at all, use "n" as the default
if [ -z "$(tmux show-option -gq "@tmux_layouts_new_pane_key" 2>/dev/null)" ]; then
  NEW_PANE_KEY="n"
fi

if [ -n "$NEW_PANE_KEY" ]; then
  tmux bind-key "$NEW_PANE_KEY" run-shell "\"$PLUGIN_DIR/scripts/new_pane.sh\""
fi

# ─────────────────────────────────────────────────────────────────────────────
#  Initialise all existing windows from user config
#  (needed when `tmux source ~/.tmux.conf` is run inside a live session)
# ─────────────────────────────────────────────────────────────────────────────
tmux run-shell "\"$PLUGIN_DIR/scripts/init_all_windows.sh\" \"$PLUGIN_DIR\""