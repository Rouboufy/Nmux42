# Nmux42

A personalized Neovim and Tmux setup for development, synchronized with my current settings.

## 🚀 Installation

```bash
git clone https://github.com/Rouboufy/config.git
cd config
./setup.sh
```

## ✨ Features

- **Cross-Platform Support**: Works seamlessly on **macOS** and **Linux**.
- **Smart Dependency Management**: 
    - Automatically checks for and installs required software: `Neovim`, `Tmux`, `Git`, and `Curl`.
    - **Intelligent Privilege Handling**: Uses system package managers (`apt`, `dnf`, `yum`, `pacman`) if `sudo` is available.
    - **Homebrew Fallback**: If you don't have sudo privileges, the script automatically uses **Homebrew** to install dependencies.
- **Zero-Config Deployment**: Sets up your environment in one go.

## ⌨️ Keybindings & Shortcuts

### General
| Shortcut | Action |
|----------|--------|
| `<leader>cd` | Open File Explorer (NetRW) |

### 🔭 Telescope (Search)
| Shortcut | Action |
|----------|--------|
| `<leader>ff` | **F**ind **F**iles |
| `<leader>fg` | **F**ind **G**rep (Live text search) |
| `<leader>fb` | **F**ind **B**uffers |
| `<leader>fh` | **F**ind **H**elp tags |

### ⚓ Harpoon
| Shortcut | Action |
|----------|--------|
| `<leader>a` | Add file to Harpoon |
| `Ctrl+e` | Toggle Harpoon Menu |

### 🧠 LSP (Language Server)
| Shortcut | Action |
|----------|--------|
| `gd` | Go to Definition |
| `K` | Hover Documentation |
| `gi` | Go to Implementation |
| `gr` | Go to References |
| `<space>rn` | Rename Symbol |
| `<space>ca` | Code Action |
| `<space>e` | Open Diagnostics (Error) Float |
| `[d` / `]d` | Previous / Next Diagnostic |

### 🖥️ Tmux Navigation
| Shortcut | Action |
|----------|--------|
| `Ctrl+h` | Move Left (Pane/Window) |
| `Ctrl+j` | Move Down (Pane/Window) |
| `Ctrl+k` | Move Up (Pane/Window) |
| `Ctrl+l` | Move Right (Pane/Window) |
| `Ctrl+a` | Tmux Prefix |

## 📦 Plugins Included
- **Core**: `lazy.nvim`, `plenary.nvim`
- **UI**: `tokyonight.nvim` (Theme), `lualine.nvim`
- **Navigation**: `telescope.nvim`, `vim-tmux-navigator`, `harpoon`
- **Coding**: `blink.cmp` (Completion), `nvim-lspconfig`, `mason.nvim`
- **Utils**: `vim-fugitive`, `nvim-osc52`, `nvim-colorizer.lua`
- **Syntax**: `nvim-treesitter`
