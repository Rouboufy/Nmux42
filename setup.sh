#!/bin/bash

# ========================================
# Neovim & Tmux Setup Script (42 Optimized)
# Author: Rouboufy
# ========================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# OS Check
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;; 
    Darwin*)    MACHINE=Mac;; 
    *)          MACHINE="UNKNOWN:${OS}";;
esac

# Homebrew Installation (42 Aware)
ensure_brew() {
    if command_exists brew; then
        print_success "Homebrew is already installed."
        return
    fi

    print_info "Homebrew not found. Starting installation..."

    if ! command_exists curl; then
        print_error "curl is required to install Homebrew. Please install curl first."
        exit 1
    fi

    # Install Homebrew
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Load Brew into current session
    if [ "$MACHINE" = "Linux" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || eval "$(~/.linuxbrew/bin/brew shellenv)"
    else
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)"
    fi

    if ! command_exists brew; then
        print_error "Homebrew installation failed or is not in PATH."
        exit 1
    fi
    print_success "Homebrew installed successfully."
}

# Enhanced Package Installer
install_package() {
    PACKAGE=$1
    if command_exists "$PACKAGE"; then
        print_success "$PACKAGE is already installed."
        return
    fi

    print_info "Installing $PACKAGE via Homebrew..."
    ensure_brew
    brew install "$PACKAGE"
}

install_opencode() {
    if command_exists opencode; then
        print_success "OpenCode is already installed."
        return
    fi

    print_info "Attempting to install OpenCode..."
    # Attempting npm install for opencode if node exists
    if command_exists npm; then
        npm install -g opencode 2>/dev/null || print_warning "npm install -g opencode failed. Please install manually."
    else
        print_warning "Node/NPM not found. Skipping OpenCode automatic installation."
    fi
}

setup_path() {
    print_info "Configuring shell environment (.zshrc)..."
    ZSHRC="$HOME/.zshrc"
    touch "$ZSHRC"

    # Add Local Bins
    if ! grep -q "export PATH=\"\$HOME/.local/bin:\$HOME/.cargo/bin:\$PATH\"" "$ZSHRC"; then
        echo 'export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"' >> "$ZSHRC"
    fi

    # Add Homebrew to PATH permanently
    if ! grep -q "brew shellenv" "$ZSHRC"; then
        if [ "$MACHINE" = "Linux" ]; then
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$ZSHRC"
        else
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$ZSHRC"
        fi
    fi
    print_success "PATH updated in .zshrc"
}

setup_starship() {
    print_info "Configuring Starship..."
    mkdir -p ~/.config
    
    # Copy starship.toml from current directory if it exists
    if [ -f "./starship.toml" ]; then
        cp ./starship.toml ~/.config/starship.toml
        print_success "Starship config installed from starship.toml"
    else
        print_warning "starship.toml not found in current directory. Creating basic config."
        echo 'format = "$all"' > ~/.config/starship.toml
    fi

    # Add to .zshrc
    ZSHRC="$HOME/.zshrc"
    if ! grep -q "starship init zsh" "$ZSHRC"; then
        echo 'eval "$(starship init zsh)"' >> "$ZSHRC"
        print_success "Added Starship init to .zshrc"
    fi
}

setup_tmux() {
    print_info "Configuring Tmux..."
    cat > ~/.tmux.conf << 'EOF'
# Prefix key
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Basic Settings
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on

# Key Bindings
bind r source-file ~/.tmux.conf \; display "Config reloaded!"
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Navigate panes (Vim style)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# TPM Plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'christoomey/vim-tmux-navigator'

# Initialize TPM
if "test ! -d ~/.tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

run '~/.tmux/plugins/tpm/tpm'
EOF
    print_success "Tmux configured."
}

setup_neovim() {
    print_info "Writing Neovim configuration..."
    mkdir -p ~/.config/nvim
    cat > ~/.config/nvim/init.lua << 'EOF'
vim.opt.termguicolors = true
print("I use Neovim btw")
vim.env.PATH = vim.fn.expand("~/.local/bin") .. ":" .. vim.fn.expand("~/.cargo/bin") .. ":" .. vim.env.PATH

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
  { "folke/tokyonight.nvim", config = function() vim.cmd.colorscheme("tokyonight") end },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = { theme = 'tokyonight' } },
  { "saghen/blink.cmp", version = "*", opts = { keymap = { preset = "default" }, sources = { default = { "lsp", "path", "snippets", "buffer" } } } },
  { "ThePrimeagen/harpoon", config = function() local h = require("harpoon") vim.keymap.set("n", "<leader>a", function() h:list():add() end) end },
  { "zbirenbaum/copilot.lua", cmd = "Copilot", event = "InsertEnter", config = function() require("copilot").setup({ suggestion = { enabled = true, auto_trigger = true, keymap = { accept = "<M-l>" } } }) end },
  { "neovim/nvim-lspconfig" },
  { "mason-org/mason.nvim" },
  { "tpope/vim-fugitive" },
  { "ojroques/nvim-osc52" },
  { "norcalli/nvim-colorizer.lua", config = function() require("colorizer").setup() end },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "christoomey/vim-tmux-navigator", lazy = false },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", opts = { highlight = { enable = true }, ensure_installed = { "c", "lua", "vim", "python" }, auto_install = true }, config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end },
})

require("mason").setup()
if vim.lsp.enable then
  vim.lsp.enable({"clangd", "lua_ls", "python"})
end
EOF
    print_success "Neovim configured."
}

# Main Execution
main() {
    print_info "Starting Full Setup..."
    
    mkdir -p ~/.config ~/.local/bin ~/.tmux/plugins
    
    setup_path
    ensure_brew
    
    install_package nvim
    install_package tmux
    install_package starship
    
    setup_neovim
    setup_tmux
    setup_starship
    install_opencode
    
    print_success "Setup Complete! PLEASE RUN: source ~/.zshrc"
    print_info "Then run 'nvim' to finish plugin installation."
}

main "$@"
