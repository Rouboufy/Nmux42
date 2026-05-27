```
  _   _                            _  _    ____   
 | \ | | _ __ ___   _   _ __  __  | || |  |___ \  
 |  \| || '_ ` _ \ | | | |\ \/ /  | || |_   __) | 
 | |\  || | | | | || |_| | >  <   |__   _| / __/  
 |_| \_||_| |_| |_| \__,_|/_/\_\     |_|  |_____| 
```

<div align="center">

![Version](https://img.shields.io/badge/version-v0.0.2--nightly-7c6af5?style=flat-square)
![Platform](https://img.shields.io/badge/platform-42%20School-5ddbb8?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Arch%20Linux-1793d1?style=flat-square&logo=arch-linux&logoColor=white)
![Platform](https://img.shields.io/badge/platform-macOS-f5876a?style=flat-square&logo=apple&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-888888?style=flat-square)

**A professional, high-performance development environment for 42 School, Arch Linux, and macOS.**
One-command setup for Neovim, Tmux, Zsh, and Bash.

</div>

---

## 🚀 Quick Start

```bash
git clone https://github.com/Rouboufy/Nmux42.git
cd Nmux42
bash setup.sh
```

| Action | Command |
|--------|---------|
| **Install** | `bash setup.sh` |
| **Update** | `bash update.sh` or press `u` on the Neovim dashboard |
| **Uninstall** | `bash uninstall.sh` |
| **Disable Tmux only** | `bash uninstall.sh --disable-tmux` |

---

## ✨ Smart Features

Nmux42 detects your environment and adapts automatically — no manual tweaking needed.

- **Arch Linux native** — detects Arch and uses `pacman` with `sudo` for high-performance native binaries
- **100% Sudo-free** — bypasses root requirements for Homebrew and NPM installs, works on 42 clusters
- **SSL proxy fix** — automatically applies `strict-ssl false` for the 42 network proxy
- **Node auto-upgrade** — upgrades Node.js to LTS via `nvm` if the system version is too old
- **Auto PATH management** — handles `~/.local/bin`, `~/.cargo/bin`, and Homebrew paths automatically
- **Cleanup routine** — removes temp files and build caches (NPM/Brew) after install to save disk space

---

## 📦 What's Included

### Core Applications

| Tool | Description |
|------|-------------|
| **Neovim** | Custom plugin manager, Neo-tree explorer, interactive dashboard, [Japonette TUI](https://github.com/sakemyali/japonette), live theme selector, LSP support |
| **Tmux** | `Ctrl-a` prefix, pane navigation shortcuts, automatic color sync with the active Neovim colorscheme |
| **Zsh / Bash** | Optimized configurations for both shells with clean prompts |
| **JetBrainsMono Nerd Font** | Auto-installed to `~/.local/share/fonts/` (no sudo) — required for icons |

### Compilers & Runtimes

**Always installed:**
`gcc` · `clang` · `python3` · `go` · `ripgrep` · `fd-find` · `pyright`

**Optional** *(prompted during setup):*
`zig` · `node.js` · `typescript` · `javascript` · `japonette`

---

## ⌨️ Keybindings

> Leader key is `Space`.

### General

| Shortcut | Action |
|----------|--------|
| `<leader>e` | Toggle file explorer (Neo-tree) |
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Live grep (Telescope) |
| `<leader>a` | Add file to Harpoon |
| `Ctrl+e` | Toggle Harpoon menu |
| `<leader>th` | Select colorscheme — live preview + Tmux sync |
| `<leader>db` | Return to welcome dashboard |
| `<leader>ft` | Toggle floating terminal (Flterm) |
| `<leader>hk` | Custom keybinds quick-help popup |
| `<leader>hp` | Plugin manager / list popup |
| `<leader>vb` / `<leader>?` | Vim bindings reference |

### Git

| Shortcut | Action |
|----------|--------|
| `<leader>gg` | Open Git TUI (LazyGit with smart fallback) |
| `<leader>gl` | Open Git log |
| `<leader>gd` | Open Git diff |
| `<leader>gf` | LazyGit file log / filter |
| `<leader>gc` | LazyGit current file history |
| `<leader>gs` | Stage hunk under cursor |
| `<leader>gr` | Reset hunk under cursor |
| `<leader>gS` | Stage entire buffer |
| `<leader>gu` | Undo last staged hunk |
| `<leader>gp` | Preview hunk inline |
| `<leader>gb` | Toggle inline git blame |
| `]h` / `[h` | Jump to next / previous hunk |
| `ih` | Text object: select hunk (operator/visual mode) |

### Japonette TUI

| Key | Action |
|-----|--------|
| `<leader>Ja` | Open Japonette — Active Campus tab |
| `<leader>Jf` | Open Japonette — Friends Watchlist tab |
| `<leader>Jm` | Open Japonette — Cluster Map tab |
| `Tab` | Toggle between tabs |
| `1` / `2` / `3` | Switch to Campus / Friends / Cluster tab directly |
| `r` | Reload from 42 Intra API |
| `a` / `d` | Add / remove friend from watchlist |
| `Enter` / `o` | Inspect user details in popup |
| `m` | View user location on Cluster Map |
| `L` | Search for a specific user's location |
| `c` | Set default campus slug |
| `C` | Show a specific cluster map by name |
| `q` / `Esc` | Close Japonette window |

### Tmux

| Shortcut | Action |
|----------|--------|
| `Ctrl+a` | Prefix key (replaces default `Ctrl+b`) |
| `Ctrl+a` `\|` | Split pane vertically |
| `Ctrl+a` `-` | Split pane horizontally |
| `Alt+h/j/k/l` | Navigate panes — no prefix needed |

---

## 🎨 Themes

Press `<Space>th` to open the live theme selector. Selecting a theme automatically updates Tmux colors to match.

`Catppuccin` · `TokyoNight` · `Cyberdream` · `Rose Pine` · `Gruvbox` · `Nord` · `Kanagawa` · `Nightfox` · `Matte Black` · `Aether`

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for instructions on how to get started.

---

## 🗑️ Uninstall

**Interactive menu** — prompts you to choose between full removal or disabling Tmux only:
```bash
bash uninstall.sh
```

**Disable Tmux auto-launch only** — keeps all plugins and configs intact:
```bash
bash uninstall.sh --disable-tmux
```

> A backup is created (e.g., `~/.zshrc.pre-tmux-disable`) before any shell configuration modifications.
> During a full uninstall, the script prompts before removing NVM or Homebrew.

---

## 🛠️ Post-Installation

1. **Restart your terminal** after running `setup.sh`.
2. Your terminal will **automatically open inside a tmux session** (`main`) on every launch.
3. Open Neovim (`nvim`) — the plugin manager will **download all plugins automatically** on first boot.
4. Set your terminal emulator font to **JetBrainsMono Nerd Font** (or `JetBrainsMono NF`). Already installed at `~/.local/share/fonts/`.
5. Run `:Mason` inside Neovim to manage additional LSPs and formatters.

---

## 📂 Generated Shell Configurations

The setup script produces clean, organized `.zshrc` and `.bashrc` files:

| Section | Contents |
|---------|----------|
| **Environment** | PATH exports for local NPM, Go binaries, Cargo, Homebrew |
| **Homebrew** | Auto-detection and loading for Homebrew/Linuxbrew |
| **Auto-Tmux** | Logic to attach to or create a session on startup |
| **Aliases** | `v` → `nvim` · `ll` → long list · `gs` → `git status` |
| **Prompt** | Fast, clean shell prompt |

