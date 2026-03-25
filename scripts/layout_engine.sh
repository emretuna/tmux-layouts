#!/bin/sh
# scripts/layout_engine.sh
# Core layout algorithms. Sourced by other scripts — do not execute directly.
# POSIX-compatible - works in any shell (sh, bash, zsh, fish).

# ─────────────────────────────────────────────────────────────────────────────
#  Helpers
# ─────────────────────────────────────────────────────────────────────────────

get_panes() {
  tmux list-panes -t "$1" -F '#{pane_id}' 2>/dev/null
}

pane_count() {
  get_panes "$1" | wc -l | tr -d ' '
}

window_width()  { tmux display-message -t "$1" -p '#{window_width}'  2>/dev/null; }
window_height() { tmux display-message -t "$1" -p '#{window_height}' 2>/dev/null; }

# ─────────────────────────────────────────────────────────────────────────────
#  VSTACK
#  One main pane left, vertical stack on the right.
#
#  ┌──────┬───┐
#  │      │ 2 │
#  │  1   ├───┤
#  │      │ 3 │
#  └──────┴───┘
# ─────────────────────────────────────────────────────────────────────────────
layout_vstack() {
  window="$1"
  main_ratio="${2:-0.5}"

  panes=$(get_panes "$window")
  n=$(echo "$panes" | wc -l | tr -d ' ')
  [ "$n" -le 1 ] && return

  W=$(window_width "$window")
  main_w=$(awk "BEGIN{printf \"%d\", $W * $main_ratio}")

  first_pane=$(echo "$panes" | head -1)

  tmux select-layout -t "$window" main-vertical 2>/dev/null
  tmux resize-pane -t "$first_pane" -x "$main_w" 2>/dev/null
}

# ─────────────────────────────────────────────────────────────────────────────
#  HSTACK
#  One main pane on top, horizontal row below.
#
#  ┌──────────┐
#  │    1     │
#  ├───┬───┬──┤
#  │ 2 │ 3 │4 │
#  └───┴───┴──┘
# ─────────────────────────────────────────────────────────────────────────────
layout_hstack() {
  window="$1"
  main_ratio="${2:-0.5}"

  panes=$(get_panes "$window")
  n=$(echo "$panes" | wc -l | tr -d ' ')
  [ "$n" -le 1 ] && return

  H=$(window_height "$window")
  main_h=$(awk "BEGIN{printf \"%d\", $H * $main_ratio}")

  first_pane=$(echo "$panes" | head -1)

  tmux select-layout -t "$window" main-horizontal 2>/dev/null
  tmux resize-pane -t "$first_pane" -y "$main_h" 2>/dev/null
}

# ─────────────────────────────────────────────────────────────────────────────
#  SPIRAL
#  Each new pane splits the previous one, alternating vertical / horizontal.
#  The spiral structure is created by the split sequence in new_pane.sh.
#  Do nothing here to preserve the split-created arrangement.
# ─────────────────────────────────────────────────────────────────────────────
layout_spiral() {
  window="$1"
  panes=$(get_panes "$window")
  n=$(echo "$panes" | wc -l | tr -d ' ')
  [ "$n" -le 1 ] && return
  # Do nothing - the spiral is created by split sequence
}

# ─────────────────────────────────────────────────────────────────────────────
#  Dispatcher
# ─────────────────────────────────────────────────────────────────────────────
apply_layout() {
  layout="$1"
  window="$2"
  case "$layout" in
    vstack) layout_vstack "$window" ;;
    hstack) layout_hstack "$window" ;;
    spiral) layout_spiral "$window" ;;
  esac
}