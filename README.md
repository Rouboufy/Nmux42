# Nmux42

A personalized Neovim and Tmux setup for development, featuring AI integration, efficient navigation, and modern aesthetics.

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
    - **Auto-Homebrew**: If Homebrew is missing and needed, the script will install it for you locally.
- **Zero-Config Deployment**: Clones plugins and sets up your environment in one go.

## ⌨️ Keybindings & Shortcuts

### General
| Shortcut | Action |
|----------|--------|
| `<leader>pv` | Open File Explorer (NetRW) |
| `<leader>wq` | Save and Quit |
| `<leader>lsp` | Manually start LSP (Clangd) |

### 🔭 Telescope (Search)
| Shortcut | Action |
|----------|--------|
| `<leader>sf` | **S**earch **F**iles (Find files) |
| `<leader>fg` | **F**ind **G**rep (Live text search) |
| `<leader>fb` | **F**ind **B**uffers (Switch open files) |
| `<leader>fh` | **F**ind **H**elp tags |

### 🌲 NvimTree (File Tree)
| Shortcut | Action |
|----------|--------|
| `<leader>t` | Toggle File Tree |

### 🤖 OpenCode (AI Assistant)
| Shortcut | Action |
|----------|--------|
| `<leader>oc` | Open OpenCode (or with selection) |
| `<leader>og` | Toggle OpenCode Window |
| `<leader>oi` | Open Input Window |
| `<leader>oI` | Open Input (New Session) |
| `<leader>oo` | Open Output Window |
| `<leader>oh` | Select from History |
| `<leader>os` | Select Session |
| `<leader>oR` | Rename Session |
| `<leader>op` | Configure Provider |
| `<leader>ov` | Paste Image from Clipboard |
| `<leader>oz` | Toggle Zoom |

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

### 💬 Comments (NERDCommenter)
| Shortcut | Action |
|----------|--------|
| `<leader>cc` | Comment Line(s) |
| `<leader>cu` | Uncomment Line(s) |
| `<leader>c<space>` | Toggle Comment |

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
- **UI**: `catppuccin` (Theme), `nvim-tree`
- **Navigation**: `telescope.nvim`, `vim-tmux-navigator`
- **Coding**: `nvim-cmp` (Completion), `nvim-lspconfig`, `luasnip`, `nerdcommenter`
- **AI**: `opencode.nvim`
- **Syntax**: `nvim-treesitter`

## ⚙️ Custom Commands
- `:OpenCodeInfo` - Show OpenCode usage and help.
- `:LspStart` - Start the Clangd LSP manually if not auto-started.
