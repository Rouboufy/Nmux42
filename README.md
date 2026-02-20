# Nmux42

A professional, high-performance development environment for **42 School**, **Arch Linux**, and **macOS**. This repository provides a "one-command" setup for Neovim, Tmux, Zsh, and essential compilers.

## 🚀 One-Command Installation

Clone and run the smart setup script:

```bash
git clone https://github.com/Rouboufy/Nmux42.git
cd Nmux42
bash setup.sh
```

## ✨ "Smart" Features

- **Arch Linux Native**: Automatically detects Arch and uses `pacman` with `sudo` for high-performance native binaries.
- **42 School & macOS Optimized**: Falls back to **Homebrew** if `sudo` is unavailable or on macOS.
- **Auto-Configured Shell**: Generates a clean, organized `.zshrc` with auto-loading for Homebrew, aliases, and Starship.
- **Automated PATH Management**: Handles `~/.local/bin`, `~/.cargo/bin`, and Homebrew paths automatically.

## 📦 What's Included?

### Core Applications
- **Neovim (v0.10+)**: Modern Lua-based config with Lazy.nvim.
- **Tmux**: Power-user configuration with `Ctrl-a` prefix and seamless Vim navigation.
- **Starship**: Fast, customizable shell prompt.
- **Zsh**: Automatically configured as the default shell.

### Compilers & Runtimes (Auto-Installed)
- **C/C++**: `gcc`, `clang`
- **Python**: `python3` (with `pyright` LSP)
- **Go**: `go`
- **Optional**: `Zig`, `Node.js`, `TypeScript`, `JavaScript` (via interactive prompts).

## ⌨️ Keybindings

### 🧠 GitHub Copilot
| Shortcut | Action |
|----------|--------|
| **`Alt + l`** | **Accept Suggestion** (Ghost Text) |
| `:Copilot setup` | Initial Authentication |

### 🔭 Neovim (Leader is Space)
| Shortcut | Action |
|----------|--------|
| `<leader>cd` | Open File Explorer (NetRW) |
| `<leader>ff` | Find Files (Telescope) |
| `<leader>fg` | Live Grep (Telescope) |
| `<leader>a` | Add file to Harpoon |
| `Ctrl + e` | Toggle Harpoon Menu |

### 🖥️ Tmux & Navigation
| Shortcut | Action |
|----------|--------|
| **`Ctrl + a`** | **Prefix Key** (instead of Ctrl-b) |
| `Ctrl + a` followed by `|` | Split Vertical |
| `Ctrl + a` followed by `-` | Split Horizontal |
| **`Ctrl + h/j/k/l`** | **Direct Navigation** between Tmux panes AND Neovim splits (No prefix needed!) |

## 🛠️ Post-Installation
1. **Restart your terminal** after running `setup.sh`.
2. Open Neovim (`nvim`) and wait for `lazy.nvim` to install plugins.
3. Run `:Copilot setup` to link your GitHub account.
4. Run `:Mason` to manage additional LSPs and formatters.

## 📂 Organized .zshrc
The script generates a structured `.zshrc` including:
- **Environment**: Proper PATH exports for all your tools.
- **Homebrew**: Auto-detection and loading.
- **Aliases**: `v` (nvim), `ll` (long list), `gs` (git status).
- **History**: Optimized history settings and completions.
- **Starship**: Initialized at the very end for maximum compatibility.
