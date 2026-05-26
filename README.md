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

## 🔄 Update

You can update Nmux42 directly from the Neovim dashboard by pressing **`u`**, or manually by running:

```bash
bash update.sh
```

## 🗑️ Uninstallation & Configuration

Nmux42 includes a versatile uninstaller that can either revert everything or just tweak specific behaviors.

### Options:

1.  **Full Uninstall**: Reverts all changes, removes `~/.config/nvim`, `~/.config/tmux`, and attempts to restore your original `.zshrc` from the backup created during installation.
2.  **Disable Tmux Auto-launch**: Removes only the logic that automatically starts tmux when you open a terminal, keeping all other configurations and plugins intact.

### Commands:

**Interactive Menu:**
```bash
bash uninstall.sh
```
*Follow the prompts to choose between a full uninstall or disabling tmux.*

**Quick Disable (Tmux Only):**
```bash
bash uninstall.sh --disable-tmux
```

### 🛡️ Safety
- Before modifying your `.zshrc` to disable tmux, a backup is automatically created at `~/.zshrc.pre-tmux-disable`.
- During a full uninstall, the script will prompt you before removing larger components like NVM or Homebrew.

## ✨ "Smart" Features

- **Arch Linux Native**: Automatically detects Arch and uses `pacman` with `sudo` for high-performance native binaries.
- **42 School & Cluster Optimized**: 
    - **100% Sudo-free**: Bypasses root requirements for Homebrew and NPM global installs.
    - **SSL Fix**: Automatically bypasses certificate errors on the 42 network proxy (`strict-ssl false`).
    - **Node Management**: Automatically upgrades Node.js to LTS via `nvm` if the system version is too old for modern tools.
- **Auto-Configured Shell**: Generates a clean, organized `.zshrc` with auto-loading for Homebrew, aliases, and custom prompt.
- **Automated PATH Management**: Handles `~/.local/bin`, `~/.cargo/bin`, and Homebrew paths automatically.
- **Cleanup Routine**: The installer automatically cleans up temporary download files and build caches (NPM/Brew) to save space.

## 📦 What's Included?

### Core Applications
- **Neovim**: Customized with a custom stable plugin manager, Neo-tree explorer, colorful interactive welcome dashboard, [Japonette TUI](https://github.com/sakemyali/japonette) integration, interactive theme selector, and LSP settings.
- **Tmux**: Power-user configuration with `Ctrl-a` prefix, pane navigation shortcuts, and **automatic color sync with the active Neovim colorscheme**.
- **Zsh**: Automatically configured as the default shell with a clean prompt. **Auto-attaches to a tmux session** on every terminal open.
- **JetBrainsMono Nerd Font**: Automatically downloaded and installed to `~/.local/share/fonts` (no sudo). Required for icons in Neo-tree, lualine, and the dashboard.

### Compilers & Runtimes (Auto-Installed)
- **C/C++**: `gcc`, `clang`, `ripgrep`, `fd-find` (essential for fast fuzzy finding).
- **Python**: `python3` (with `pyright` LSP).
- **Go**: `go`.
- **Optional**: `Zig`, `Node.js`, `TypeScript`, `JavaScript`, `Japonette` (via interactive prompts).

## ⌨️ Keybindings

### 🔭 Neovim (Leader is Space)

#### General Keybinds
| Shortcut | Action |
|----------|--------|
| `<leader>e` | **Toggle File Explorer** (Neo-tree) |
| `<leader>ff` | Find Files (Telescope) |
| `<leader>fg` | Live Grep (Telescope) |
| `<leader>a` | Add file to Harpoon |
| `Ctrl + e` | Toggle Harpoon Menu |
| `<leader>Ja` | **Open Japonette TUI** (Active Campus tab) |
| `<leader>Jf` | **Open Japonette TUI** (Friends Watchlist tab) |
| `<leader>th` | **Select Colorscheme TUI** (live preview + tmux sync) |
| `<leader>vb` / `<leader>?` | **Vim Bindings Reference** (motions + custom keys) |
| `<leader>hk` | Custom Nmux42 keybinds quick-help popup |
| `<leader>hp` | Plugins manager / list popup |
| `<leader>db` | **Return to welcome dashboard** |
| `<leader>ft` | Toggle floating terminal (Flterm) |

#### 🌿 Git Keybinds (Unified TUI + Gitsigns)
| Shortcut | Action |
|----------|--------|
| `<leader>gg` | **Open Git TUI** (LazyGit with smart fallback) |
| `<leader>gl` | Open Git Log (Custom TUI) |
| `<leader>gd` | Open Git Diff (Custom TUI) |
| `<leader>gf` | LazyGit file log / filter |
| `<leader>gc` | LazyGit current file history |
| `<leader>gs` | Gitsigns: stage hunk under cursor |
| `<leader>gr` | Gitsigns: reset hunk under cursor |
| `<leader>gS` | Gitsigns: stage entire buffer |
| `<leader>gu` | Gitsigns: undo last staged hunk |
| `<leader>gp` | Preview hunk inline |
| `<leader>gb` | Toggle inline git blame |
| `]h` / `[h` | Jump to next / previous git hunk |
| `ih` | Text object: select hunk (in operator/visual mode) |

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

## 🎨 Theme Selection & Sync
Nmux42 comes with preinstalled premium themes: **Catppuccin, TokyoNight, Cyberdream, Rose Pine, Gruvbox, Nord, Kanagawa, Nightfox, Matte Black, and Aether**.

1. Press `<Space>th` inside Neovim.
2. Scroll through the themes on the left; the code preview on the right updates in real-time.
3. Press **Enter** to save. **Tmux colors will automatically update to match!**

## 🛠️ Post-Installation
1. **Restart your terminal** after running `setup.sh`.
2. Your terminal will **automatically open inside a tmux session** (`main`) on every launch.
3. Open Neovim (`nvim`) and wait for the custom plugin manager to download/clone the plugins automatically on first boot.
4. **Set your terminal emulator font** to `JetBrainsMono Nerd Font` (or `JetBrainsMono NF`) for all icons to render correctly. The font is already installed to `~/.local/share/fonts/` by the setup script.
5. Run `:Mason` to manage additional LSPs and formatters.

## 📂 Organized .zshrc
The script generates a structured `.zshrc` including:
- **Environment**: Proper PATH exports for all your tools, including local NPM and Go binaries.
- **Homebrew**: Auto-detection and loading for Linuxbrew.
- **Auto-Tmux**: Logic to attach to or create a session on startup.
- **Aliases**: `v` (nvim), `ll` (long list), `gs` (git status).
- **Prompt**: A fast, clean shell prompt initialized at the end.
