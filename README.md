```text
  _   _                            _  _    ____   
 | \ | | _ __ ___   _   _ __  __  | || |  |___ \  
 |  \| || '_ ` _ \ | | | |\ \/ /  | || |_   __) | 
 | |\  || | | | | || |_| | >  <   |__   _| / __/  
 |_| \_||_| |_| |_| \__,_|/_/\_\     |_|  |_____| 
```

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
- **Auto-Configured Shell**: Generates a clean, organized `.zshrc` with auto-loading for Homebrew, aliases, and custom prompt.
- **Automated PATH Management**: Handles `~/.local/bin`, `~/.cargo/bin`, and Homebrew paths automatically.

## 📦 What's Included?

### Core Applications
- **Neovim**: Customized with a custom stable plugin manager, Neo-tree explorer, interactive welcome dashboard, [Japonette TUI](https://github.com/sakemyali/japonette) integration, interactive theme selector, and LSP settings.
- **Tmux**: Power-user configuration with `Ctrl-a` prefix and pane navigation shortcuts.
- **Zsh**: Automatically configured as the default shell with a clean prompt.

### Compilers & Runtimes (Auto-Installed)
- **C/C++**: `gcc`, `clang`
- **Python**: `python3` (with `pyright` LSP)
- **Go**: `go`
- **Optional**: `Zig`, `Node.js`, `TypeScript`, `JavaScript`, `Japonette` (via interactive prompts).

## ⌨️ Keybindings

### 🔭 Neovim (Leader is Space)

#### General Keybinds
| Shortcut | Action |
|----------|--------|
| `<leader>e` | **Toggle File Explorer** (Neo-tree) |
| `<leader>cd` | Open File Explorer (NetRW fallback) |
| `<leader>ff` | Find Files (Telescope) |
| `<leader>fg` | Live Grep (Telescope) |
| `<leader>a` | Add file to Harpoon |
| `Ctrl + e` | Toggle Harpoon Menu |
| `<leader>ja` | **Open Japonette TUI** (Active Campus tab) |
| `<leader>jf` | **Open Japonette TUI** (Friends Watchlist tab) |
| `<leader>th` | **Select Colorscheme TUI** (interactive selector with preview pane) |

#### Japonette TUI Buffer Controls
| Key | Action |
|-----|--------|
| `<Tab>` | Toggle between Active Campus and Friends List tabs |
| `1` | Switch to Active Campus tab |
| `2` | Switch to Friends List tab |
| `r` | Reload/Refresh the list from 42 Intra API |
| `a` | Add a 42 login to watchlist |
| `d` | Remove the friend under the cursor from watchlist |
| `Enter` / `o` | Inspect details of user under cursor in a rounded popup |
| `c` | Change/Set default campus slug |
| `h` | Show help cheatsheet |
| `q` / `<Esc>` | Close the Japonette TUI window |

### 🖥️ Tmux & Navigation
| Shortcut | Action |
|----------|--------|
| **`Ctrl + a`** | **Prefix Key** (instead of Ctrl-b) |
| `Ctrl + a` followed by `|` | Split Vertical |
| `Ctrl + a` followed by `-` | Split Horizontal |
| **`Alt + h/j/k/l`** | **Direct Navigation** between Tmux panes (No prefix needed!) |

## 🛠️ Post-Installation
1. **Restart your terminal** after running `setup.sh`.
2. Open Neovim (`nvim`) and wait for the custom plugin manager to download/clone the plugins automatically on first boot.
3. Run `:Mason` to manage additional LSPs and formatters.

## 📂 Organized .zshrc
The script generates a structured `.zshrc` including:
- **Environment**: Proper PATH exports for all your tools.
- **Homebrew**: Auto-detection and loading.
- **Aliases**: `v` (nvim), `ll` (long list), `gs` (git status).
- **History**: Optimized history settings and completions.
- **Prompt**: A fast, clean shell prompt initialized at the end.
