# Ghostty for Claude Code Users

Ghostty is a fast, GPU-accelerated terminal with excellent shell integration. It's the recommended terminal for Claude Code because of its rendering speed (long Claude outputs don't lag), native macOS feel, and first-class shell integration.

## Install

Download from https://ghostty.org or:
```bash
brew install --cask ghostty
```

## Recommended config (~/.config/ghostty/config)

```ini
# Font — JetBrains Mono or Fira Code work great with Claude's output
font-family = "JetBrains Mono"
font-size = 14

# Theme — pick one you like
theme = "Catppuccin Mocha"
# theme = "Tokyo Night"
# theme = "GitHub Dark"

# Window
window-padding-x = 8
window-padding-y = 8
window-decoration = false

# Shell integration — enables better copy/paste, prompt marking, etc.
shell-integration = detect
shell-integration-features = cursor,sudo,title

# Scrollback
scrollback-limit = 10000

# Make Ctrl-C not beep
bell = false

# Copy on select
copy-on-select = true

# Open new windows/tabs in the same directory
window-inherit-working-directory = true
```

## Why Ghostty beats alternatives for Claude Code

| Feature | Ghostty | iTerm2 | Terminal.app |
|---------|---------|--------|--------------|
| GPU rendering (no lag on long output) | ✓ | Partial | ✗ |
| Shell integration (prompt marking) | ✓ | ✓ | ✗ |
| Native macOS | ✓ | ✗ | ✓ |
| tmux support | ✓ | ✓ | ✓ |
| Config as code | ✓ | ✗ | ✗ |

## Tips for Claude Code

1. **Shell integration** — with `shell-integration = detect`, Ghostty marks each prompt. You can jump between prompts with `Cmd+Up/Down`
2. **Split panes** — `Cmd+D` splits vertically, `Cmd+Shift+D` horizontally. Run Claude in one pane, your dev server in another
3. **Quick copy** — `copy-on-select = true` means any text you highlight is instantly in your clipboard — great for grabbing Claude's code snippets
4. **Cmd+K** — clears the screen without losing scrollback (better than `clear`)

## Fonts that work well with Claude Code output

- **JetBrains Mono** — excellent ligatures, great for code blocks
- **Fira Code** — clean, readable
- **Monaspace Neon** — modern, distinct italics for comments
- **Berkeley Mono** — premium feel, very readable at small sizes

Install any via: `brew install --cask font-jetbrains-mono`
