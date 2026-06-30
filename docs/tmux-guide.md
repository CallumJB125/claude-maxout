# tmux for Claude Code Users

tmux keeps your Claude Code session alive even when you close your terminal, lets you split panes to watch logs alongside Claude, and makes long-running tasks easier to manage.

## Install

```bash
brew install tmux   # macOS
apt install tmux    # Ubuntu/Debian
```

## Minimal config (~/.tmux.conf)

Copy this to `~/.tmux.conf`:

```tmux
# Use Ctrl-a as prefix (easier than Ctrl-b)
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1

# Mouse support — click to switch panes
set -g mouse on

# Increase scrollback buffer
set -g history-limit 10000

# Status bar — show session name and time
set -g status-right '%H:%M '
set -g status-left '[#S] '

# Reload config with prefix + r
bind r source-file ~/.tmux.conf \; display "Reloaded"

# Split panes with | and -
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Vi-style pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Don't rename windows automatically
set-option -g allow-rename off
```

## Essential commands

| Action | Command |
|--------|---------|
| New session | `tmux new -s claude` |
| Attach to session | `tmux attach -t claude` |
| List sessions | `tmux ls` |
| New window | `Ctrl-a c` |
| Switch window | `Ctrl-a 1` (or 2, 3...) |
| Split horizontal | `Ctrl-a \|` |
| Split vertical | `Ctrl-a -` |
| Navigate panes | `Ctrl-a h/j/k/l` |
| Detach (keep running) | `Ctrl-a d` |

## Recommended Claude Code workflow

```bash
# Start a named session for your project
tmux new -s myproject

# In the main pane: run Claude
claude

# Split a second pane for watching logs / running tests
# Ctrl-a | then in the new pane:
npm run dev
```

## Tips for Claude Code

1. **Always run Claude inside tmux** — if your terminal crashes mid-task, `tmux attach` brings you straight back
2. **Name your sessions by project** — `tmux new -s bondly`, `tmux new -s claude-maxout`
3. **Use pane 1 for Claude, pane 2 for the dev server** — you can watch logs while Claude codes
4. **`Ctrl-a d` to detach** — Claude keeps running in the background while you do other things
