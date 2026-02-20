#!/bin/bash

# ========================================
# Ultimate Dev Setup Script (42 & Arch Optimized)
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

# OS/Distro Detection
OS="$(uname -s)"
IS_ARCH=false
[ -f /etc/arch-release ] && IS_ARCH=true

# Homebrew Fallback
ensure_brew() {
    if command_exists brew; then return; fi
    print_info "Homebrew not found. Installing..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ "$OS" = "Linux" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || eval "$(~/.linuxbrew/bin/brew shellenv)"
    else
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)"
    fi
}

# Smart Package Installer
install_package() {
    PACKAGE=$1
    ALT_NAME=$2 # For cases like nodejs vs node
    
    if command_exists "$PACKAGE" || ([ -n "$ALT_NAME" ] && command_exists "$ALT_NAME"); then
        print_success "$PACKAGE is already installed."
        return
    fi

    if [ "$IS_ARCH" = true ] && command_exists pacman; then
        print_info "Arch detected: Installing $PACKAGE via pacman..."
        sudo pacman -S --noconfirm "$PACKAGE"
    else
        print_info "Installing $PACKAGE via Homebrew..."
        ensure_brew
        # Re-eval brew session
        if [ "$OS" = "Linux" ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || eval "$(~/.linuxbrew/bin/brew shellenv)"
        else
            eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)"
        fi
        brew install "$PACKAGE"
    fi
}

# Ask User for Extras
ask_optional() {
    print_info "--- Optional Packages ---"
    read -p "Install Zig? (y/N): " install_zig
    read -p "Install Node.js stack (Node, TS, JS)? (y/N): " install_node

    if [[ "$install_zig" =~ ^[Yy]$ ]]; then
        install_package zig
    fi

    if [[ "$install_node" =~ ^[Yy]$ ]]; then
        if [ "$IS_ARCH" = true ]; then
            install_package nodejs
            install_package npm
        else
            install_package node
        fi
        # Install global TS
        if command_exists npm; then
            print_info "Installing TypeScript globally..."
            sudo npm install -g typescript 2>/dev/null || npm install -g typescript
        fi
    fi
}

setup_organized_zshrc() {
    print_info "Generating organized .zshrc..."
    ZSHRC="$HOME/.zshrc"
    
    # Backup existing
    [ -f "$ZSHRC" ] && cp "$ZSHRC" "${ZSHRC}.bak"

    cat > "$ZSHRC" << 'EOF'
# ========================================
# Organized ZSH Configuration
# ========================================

# --- PATH & Environment ---
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:$PATH"

# --- Homebrew ---
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -d "/opt/homebrew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- Aliases ---
alias v="nvim"
alias vi="nvim"
alias nvimconfig="cd ~/.config/nvim && v init.lua"
alias ls="ls --color=auto"
alias ll="ls -lah"
alias gs="git status"

# --- Completion & History ---
autoload -Uz compinit && compinit
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY

# --- Starship Prompt (Must be at the end) ---
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi
EOF
    print_success ".zshrc organized (Previous config backed up to .zshrc.bak)."
}

setup_tmux() {
    print_info "Configuring Tmux..."
    cat > ~/.tmux.conf << 'EOF'
unbind C-b
set -g prefix C-a
bind C-a send-prefix
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'christoomey/vim-tmux-navigator'
if "test ! -d ~/.tmux/plugins/tpm" "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"
run '~/.tmux/plugins/tpm/tpm'
EOF
}

setup_neovim() {
    print_info "Configuring Neovim..."
    mkdir -p ~/.config/nvim
    cat > ~/.config/nvim/init.lua << 'EOF'
vim.opt.termguicolors = true
vim.env.PATH = vim.fn.expand("~/.local/bin") .. ":" .. vim.fn.expand("~/.cargo/bin") .. ":" .. vim.env.PATH
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.shiftwidth = 4
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "folke/tokyonight.nvim", config = function() vim.cmd.colorscheme("tokyonight") end },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = { theme = 'tokyonight' } },
  { "saghen/blink.cmp", version = "*", opts = { keymap = { preset = "default" }, sources = { default = { "lsp", "path", "snippets", "buffer" } } } },
  { "zbirenbaum/copilot.lua", cmd = "Copilot", event = "InsertEnter", config = function() require("copilot").setup({ suggestion = { enabled = true, auto_trigger = true, keymap = { accept = "<M-l>" } } }) end },
  { "neovim/nvim-lspconfig" },
  { "mason-org/mason.nvim" },
  { "christoomey/vim-tmux-navigator", lazy = false },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", opts = { highlight = { enable = true }, ensure_installed = { "c", "lua", "vim", "python" }, auto_install = true }, config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end },
})

require("mason").setup()
if vim.lsp.enable then vim.lsp.enable({"clangd", "lua_ls", "pyright"}) end
EOF
}

main() {
    print_info "Starting Comprehensive Setup..."
    
    # Essential Tools
    install_package nvim
    install_package tmux
    install_package starship
    install_package git
    install_package curl
    install_package zsh
    
    # Compilers & Runtimes
    install_package gcc
    install_package clang
    install_package python
    install_package go
    
    # Optional Packages
    ask_optional
    
    # Configurations
    setup_organized_zshrc
    setup_tmux
    setup_neovim
    
    # Change Shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        print_info "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
    fi

    print_success "Setup Complete! PLEASE RESTART YOUR TERMINAL."
}

main "$@"
