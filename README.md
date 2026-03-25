# tmux-layouts

Dynamic pane layouts for tmux, inspired by [i3-layouts](https://github.com/eliep/i3-layouts).

Layouts are declared once in `~/.tmux.conf`. Every time you open or close a pane the
window is automatically reorganised to match.

---

## Layouts

| Name     | Description |
|----------|-------------|
| `vstack` | One main pane on the left, vertical stack of panes on the right |
| `hstack` | One main pane on top, horizontal row of panes below |
| `spiral` | Each new pane splits the previous one, alternating vertical/horizontal |

```
vstack          hstack          spiral
┌──────┬───┐    ┌──────────┐    ┌────┬───┐
│      │ 2 │    │    1     │    │    │ 2 │
│  1   ├───┤    ├───┬───┬──┤    │ 1  ├─┬─┤
│      │ 3 │    │ 2 │ 3 │4 │    │    │3│4│
│      ├───┤    └───┴───┴──┘    └────┴─┴─┘
│      │ 4 │
└──────┴───┘
```

---

## Installation

### [TPM](https://github.com/tmux-plugins/tpm) (recommended)

Add to `~/.tmux.conf` **before** the TPM `run` line:

```tmux
set -g @plugin 'emretuna/tmux-layouts'
```

Then press `prefix + I` inside tmux to install.

### Manual

```bash
git clone https://github.com/emretuna/tmux-layouts \
  ~/.tmux/plugins/tmux-layouts
```

Add to `~/.tmux.conf`:

```tmux
run '~/.tmux/plugins/tmux-layouts/tmux-layouts.tmux'
```

Reload: `tmux source ~/.tmux.conf`

---

## Configuration

All options go in `~/.tmux.conf` **before** the `run` / TPM line.

### Assign layouts

#### Global default — every new window uses this layout

```tmux
set -g @tmux_layouts_default "spiral"
```

#### Per window index — matched by the number in your status bar

```tmux
set -g @tmux_layouts_window_1 "vstack"
set -g @tmux_layouts_window_2 "hstack"
```

#### Per session name

```tmux
set -g @tmux_layouts_session_main "spiral"
set -g @tmux_layouts_session_work "vstack"
```

#### Priority (highest → lowest)

```
@tmux_layouts_window_<index>
@tmux_layouts_session_<name>
@tmux_layouts_default
```

---

### New-pane key

The plugin binds a single smart key that opens a new pane in the correct
direction for the active layout — replacing tmux's separate `%` (vertical)
and `"` (horizontal) bindings.

```tmux
# Default key: prefix + n
set -g @tmux_layouts_new_pane_key "n"
```

Change it to any key:

```tmux
set -g @tmux_layouts_new_pane_key "v"   # prefix + v
set -g @tmux_layouts_new_pane_key "|"   # prefix + |
```

Disable it entirely (keeps tmux's default `%` / `"` untouched):

```tmux
set -g @tmux_layouts_new_pane_key ""
```

Split direction per layout:

| Layout   | Split direction              |
|----------|------------------------------|
| `vstack` | horizontal — new pane right  |
| `hstack` | vertical — new pane below    |
| `spiral` | alternates vertical/horizontal |
| *(none)* | vertical — new pane below    |

---

### Pane selection on close

When a pane is closed, the plugin can automatically select the pane with the lowest index among remaining panes.

```tmux
# Enable (default)
set -g @tmux_layouts_select_lower_on_close "true"

# Disable — use tmux's default behavior
set -g @tmux_layouts_select_lower_on_close "false"
```

---

### Leader pane size

Configure the size of the first (leader) pane as a percentage of the window.

```tmux
# Default: 65%
set -g @tmux_layouts_leader_pane_percentage "75"
```

This applies to all layouts:
- `vstack`: first pane width
- `hstack`: first pane height
- `spiral`: first pane width

---

### Complete example

```tmux
# ~/.tmux.conf

# Layout defaults
set -g @tmux_layouts_default        "spiral"
set -g @tmux_layouts_window_1       "vstack"
set -g @tmux_layouts_window_2       "hstack"

# Leader pane size (default: 65)
set -g @tmux_layouts_leader_pane_percentage "75"

# New-pane key (prefix + n)
set -g @tmux_layouts_new_pane_key   "n"

# Select lowest pane on close
set -g @tmux_layouts_select_lower_on_close "true"

# TPM plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'emretuna/tmux-layouts'
run '~/.tmux/plugins/tpm/tpm'
```

---

## How it works

| Event | What happens |
|-------|-------------|
| Plugin loads / `tmux source` | `init_all_windows.sh` applies the configured layout to every existing window |
| New window created | `init_window.sh` (via `after-new-window` hook) assigns the layout from config |
| Pane opened | `apply_layout.sh` (via `after-split-window` hook) re-applies the layout |
| Pane closed | `pane_exited.sh` (via `pane-exited` hook) selects lowest index pane and re-applies layout |
| New-pane key pressed | `new_pane.sh` splits in the correct direction for the active layout |

## Requirements

- tmux ≥ 3.0
- POSIX-compatible shell (sh, bash, zsh, fish)

## License

MIT