#!/bin/bash

# ========================================
# Neovim & Tmux Setup Script
# Author: Rouboufy
# Description: Cross-platform setup for 42 School Environment
# ========================================

set -e

# ========================================
# 1. Colors & Logging
# ========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ========================================
# 2. System Checks
# ========================================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;; 
    Darwin*)    MACHINE=Mac;; 
    *)          MACHINE="UNKNOWN:${OS}"
esac

# Check Sudo Privilege
if command_exists sudo; then
    if sudo -n true 2>/dev/null; then
        HAS_SUDO=true
    elif sudo -v 2>/dev/null; then
        HAS_SUDO=true
    else
        # Try to prompt once
        print_info "Checking for sudo privileges..."
        if sudo -v; then
            HAS_SUDO=true
        else
            HAS_SUDO=false
        fi
    fi
else
    HAS_SUDO=false
fi

# ========================================
# 3. Package Management Logic
# ========================================

# Ensure Homebrew is installed and in path
ensure_brew() {
    if ! command_exists brew; then
        print_info "Homebrew not found. Installing..."
        
        # Determine install script URL
        BREW_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
        
        # Check if we can download it
        if ! command_exists curl; then
            print_error "Curl is required to install Homebrew but is missing."
            exit 1
        fi

        # Install Homebrew (Non-interactive)
        # Note: This might still prompt for sudo if not careful, but the script handles user/sudo installs.
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL $BREW_URL)"

        # Configure shell environment for the current script session
        if [ "$MACHINE" = "Linux" ]; then
            test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
            test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        elif [ "$MACHINE" = "Mac" ]; then
            test -d /opt/homebrew && eval "$(/opt/homebrew/bin/brew shellenv)"
            test -d /usr/local && eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        if ! command_exists brew; then
            print_error "Homebrew installation failed or not found in PATH."
            exit 1
        fi
        print_success "Homebrew installed successfully."
    else
        # Ensure brew env is loaded if we are in a fresh shell
        if [ "$MACHINE" = "Linux" ]; then
             test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
             test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    fi
}

# Generic Package Installer
install_package() {
    PACKAGE=$1
    
    if command_exists "$PACKAGE"; then
        print_success "$PACKAGE is already installed."
        return
    fi

    print_info "Installing $PACKAGE..."

    if [ "$HAS_SUDO" = "true" ]; then
        # Try system package managers first if we have sudo
        if command_exists apt-get; then
            sudo apt-get update -y >/dev/null 2>&1
            sudo apt-get install -y "$PACKAGE"
        elif command_exists dnf; then
            sudo dnf install -y "$PACKAGE"
        elif command_exists yum; then
            sudo yum install -y "$PACKAGE"
        elif command_exists pacman; then
            sudo pacman -S --noconfirm "$PACKAGE"
        elif command_exists brew; then
            # If on macOS with sudo (unlikely usage, but possible) or Linuxbrew
            brew install "$PACKAGE"
        else
            print_warning "No known system package manager found. Trying Homebrew..."
            ensure_brew
            brew install "$PACKAGE"
        fi
    else
        # No sudo -> Fallback to Homebrew
        print_warning "No sudo privileges. Using Homebrew..."
        ensure_brew
        brew install "$PACKAGE"
    fi

    if ! command_exists "$PACKAGE"; then
        print_error "Failed to install $PACKAGE."
        exit 1
    fi
    print_success "$PACKAGE installed."
}

# ========================================
# 4. Dependency Checks
# ========================================

check_and_install_deps() {
    print_info "Checking dependencies..."
    
    # 1. Curl (Needed for Brew/vim-plug/etc)
    install_package curl
    
    # 2. Git
    install_package git
    
    # 3. Neovim
    install_package nvim
    
    # 4. Tmux
    install_package tmux

    # 5. Starship
    install_package starship

    # 6. Node (Optional, for some LSPs)
    # check_node_version
}


# ========================================
# 5. Configuration Setup
# ========================================

setup_directories() {
    print_info "Creating directories..."
    mkdir -p ~/.config/nvim
    mkdir -p ~/.local/share/nvim
    mkdir -p ~/.local/state/nvim
    mkdir -p ~/.cache/nvim
    mkdir -p ~/.tmux/plugins
}

setup_ghostty() {
    print_info "Configuring Ghostty Terminal..."
    
    mkdir -p ~/.config/ghostty
    
    if [ ! -f ~/.config/ghostty/config ]; then
        echo "theme = catppuccin-mocha" > ~/.config/ghostty/config
        print_success "Ghostty config created with Catppuccin theme."
    else
        if ! grep -q "theme = catppuccin-mocha" ~/.config/ghostty/config; then
             # Backup existing config
             cp ~/.config/ghostty/config ~/.config/ghostty/config.bak
             # Appending theme setting
             echo "theme = catppuccin-mocha" >> ~/.config/ghostty/config
             print_success "Ghostty config updated (backup created)."
        else
             print_success "Ghostty already configured."
        fi
    fi
}

setup_starship() {
    print_info "Configuring Starship..."

    mkdir -p ~/.config
    
    # Copy/Link starship.toml if it exists in the current directory (where script is run)
    if [ -f "./starship.toml" ]; then
        cp ./starship.toml ~/.config/starship.toml
        print_success "Starship config installed."
    else
        print_warning "starship.toml not found in script directory. Using default."
    fi

    # Ensure ~/.zshrc exists
    if [ ! -f ~/.zshrc ]; then
        touch ~/.zshrc
    fi
    
    # Add starship init to .zshrc if not present
    if ! grep -q "starship init zsh" ~/.zshrc; then
        echo 'eval "$(starship init zsh)"' >> ~/.zshrc
        print_success "Added Starship init to .zshrc"
    else
        print_success "Starship already initialized in .zshrc"
    fi
}

setup_neovim() {
    print_info "Configuring Neovim..."
    
    cat > ~/.config/nvim/init.lua << 'EOF'
vim.opt.termguicolors = true
print("I use Neovim btw")
vim.env.PATH = vim.fn.expand("~/.cargo/bin") .. ":" .. vim.env.PATH

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.shiftwidth = 4

-- Keybinds
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)

-- Lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    config = function()
      vim.cmd.colorscheme("tokyonight")
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    end
  },

  -- Lualine
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      theme = 'tokyonight'
    }
  },

  -- Completion
  {
    "saghen/blink.cmp",
    version = "*",
    opts = {
      keymap = { preset = "default" },
      appearance = {
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
  },

  -- Harpoon
  {
    "ThePrimeagen/harpoon",
    config = function()
      local harpoon = require("harpoon")
      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
      vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
    end,
  },

  -- LSP and Mason
  { "neovim/nvim-lspconfig" },
  { "mason-org/mason.nvim" },

  -- One-liners/Utils
  { "tpope/vim-fugitive" },
  { "ojroques/nvim-osc52" },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep)
      vim.keymap.set("n", "<leader>fb", builtin.buffers)
      vim.keymap.set("n", "<leader>fh", builtin.help_tags)
    end,
  },

  -- Tmux Navigator
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Window Left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Window Down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Window Up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Window Right" },
    },
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "Python", "Typescript" },
      auto_install = true,
    },
    config = function(_, opts)
      local status_ok, configs = pcall(require, "nvim-treesitter.configs")
      if status_ok then
        configs.setup(opts)
      end
    end,
  },
})

-- Mason Setup
require("mason").setup()

-- LSP Enable (Neovim 0.11+ feature)
if vim.lsp.enable then
  vim.lsp.enable({"clangd", "ts_ls", "lua_ls", "python", "html.lua"})
end
EOF
}

setup_tmux() {
    print_info "Configuring Tmux..."
    
    cat > ~/.tmux.conf << 'EOF'
# ================================
# Tmux Configuration File
# ================================

# Basic Settings
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"
set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
set-environment -g COLORTERM "truecolor"

# Shell
set -g default-shell /bin/zsh
set -g default-command /bin/zsh

# Prefix key
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# History
set -g history-limit 50000

# Enable mouse support
set -g mouse on

# Window and Pane Management
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on

# Activity Monitoring
setw -g monitor-activity on
set -g visual-activity on

# Auto-rename windows
set -g automatic-rename on
set -g automatic-rename-format "#{?pane_in_mode,[tmux],#{pane_current_command}}"

# ================================
# Key Bindings
# ================================

# Reload config
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Split panes
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Navigate panes
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Resize panes
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Swap panes
bind > swap-pane -D
bind < swap-pane -U

# Create new window
bind c new-window -c "#{pane_current_path}"

# Kill window/pane
bind x confirm kill-pane
bind X confirm kill-window

# Copy mode
bind Enter copy-mode
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send -X copy-pipe-and-cancel "xclip -in -selection clipboard"
bind -T copy-mode-vi Escape send -X cancel
bind -T copy-mode-vi D send -X end-of-line
bind -T copy-mode-vi C-v send -X rectangle-toggle

# ================================
# Status Bar
# ================================

set -g status on
set -g status-position bottom
set -g status-justify left
set -g status-interval 2

# Status bar colors
set -g status-style "bg=#0a0e14,fg=#e6e1cf"
set -g status-left-length 40
set -g status-right-length 50

# Status left
set -g status-left "#[bg=#36a3d9,fg=#0a0e14,bold] #S #[bg=#0a0e14,fg=#36a3d9]"

# Status right
set -g status-right ""

# Window status
setw -g window-status-current-style "bg=#36a3d9,fg=#0a0e14,bold"
setw -g window-status-style "bg=#323232,fg=#e6e1cf"
setw -g window-status-format " #I: #W "
setw -g window-status-current-format " #I: #W "

# ================================
# Pane Colors
# ================================

set -g pane-border-style "bg=default,fg=#323232"
set -g pane-active-border-style "bg=default,fg=#36a3d9"

# ================================
# Message Colors
# ================================

set -g message-style "bg=#f29718,fg=#0a0e14,bold"
set -g message-command-style "bg=#b8cc52,fg=#0a0e14"

# ================================
# Plugin Manager (TPM)
# ================================

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'christoomey/vim-tmux-navigator'

# Plugin settings
set -g @yank_selection_mouse 'clipboard'
set -g @yank_action 'copy-pipe-no-clear'
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'
set -g @continuum-restore 'on'

# Initialize TPM (keep this line at the very bottom of tmux.conf)
if "test ! -d ~/.tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

run '~/.tmux/plugins/tpm/tpm'
EOF
}

install_tmux_plugins() {
    print_info "Installing Tmux plugins..."
    if [ ! -d ~/.tmux/plugins/tpm ]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
    # Trigger install if possible
    if [ -f ~/.tmux/plugins/tpm/bin/install_plugins ]; then
        ~/.tmux/plugins/tpm/bin/install_plugins >/dev/null 2>&1
    fi
}

create_info() {
    cat > ~/.config/nvim/SETUP_INFO.md << 'EOF'
# Development Environment Setup

## Installation Complete! 🎉

### Tmux
- Start: `tmux`
- Prefix: `Ctrl-a` (instead of Ctrl-b)
- Reload config: `Ctrl-a r`

### Neovim
- Start: `nvim`
- Explorer: `<leader>cd`
- Telescope: `<leader>ff` (find files), `<leader>fg` (grep)
- Harpoon: `<leader>a` (add), `Ctrl-e` (menu)

EOF
}

# ========================================
# 6. Main
# ========================================

main() {
    print_info "Starting Setup..."
    print_info "Detected OS: $MACHINE"
    print_info "Sudo Available: $HAS_SUDO"

    setup_directories
    check_and_install_deps
    setup_neovim
    setup_tmux
    setup_ghostty
    setup_starship
    install_tmux_plugins
    create_info

    print_success "Setup Complete! Restart your terminal."
}

main "$@"
