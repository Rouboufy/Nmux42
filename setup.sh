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

# Homebrew Installation
ensure_brew() {
    if command_exists brew; then
        return
    fi
    print_info "Homebrew not found. Installing..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ "$MACHINE" = "Linux" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || eval "$(~/.linuxbrew/bin/brew shellenv)"
    else
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)"
    fi
}

install_package() {
    PACKAGE=$1
    if command_exists "$PACKAGE"; then
        print_success "$PACKAGE is already installed."
        return
    fi
    print_info "Installing $PACKAGE..."
    ensure_brew
    brew install "$PACKAGE"
}

setup_path() {
    print_info "Configuring shell PATH..."
    for RC in "$HOME/.zshrc" "$HOME/.bashrc"; do
        [ -f "$RC" ] || touch "$RC"
        if ! grep -q "export PATH=\"\$HOME/.local/bin:\$HOME/.cargo/bin:\$PATH\"" "$RC"; then
            echo 'export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"' >> "$RC"
        fi
        if ! grep -q "brew shellenv" "$RC"; then
            if [ "$MACHINE" = "Linux" ]; then
                echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$RC"
            else
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$RC"
            fi
        fi
    done
}

setup_starship() {
    print_info "Configuring Starship..."
    mkdir -p ~/.config
    [ -f "./starship.toml" ] && cp ./starship.toml ~/.config/starship.toml

    # Add to .zshrc
    if [ -f "$HOME/.zshrc" ] && ! grep -q "starship init zsh" "$HOME/.zshrc"; then
        echo -e '\n# Starship Prompt\neval "$(starship init zsh)"' >> "$HOME/.zshrc"
        print_success "Added Starship to .zshrc"
    fi
    # Add to .bashrc
    if [ -f "$HOME/.bashrc" ] && ! grep -q "starship init bash" "$HOME/.bashrc"; then
        echo -e '\n# Starship Prompt\neval "$(starship init bash)"' >> "$HOME/.bashrc"
        print_success "Added Starship to .bashrc"
    fi
}

setup_tmux() {
    print_info "Configuring Tmux..."
    cat > ~/.tmux.conf << 'EOF'
# Prefix
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Quality of Life
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"

# Splits
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %

# Tmux-Navigator (Vim Style)
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'

# TPM Plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'christoomey/vim-tmux-navigator'

if "test ! -d ~/.tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

run '~/.tmux/plugins/tpm/tpm'
EOF
    print_success "Tmux configured."
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
  { "zbirenbaum/copilot.lua", cmd = "Copilot", event = "InsertEnter", config = function() require("copilot").setup({ suggestion = { enabled = true, auto_trigger = true, keymap = { accept = "<C-CR>" } } }) end },
  { "neovim/nvim-lspconfig" },
  { "mason-org/mason.nvim" },
  { "christoomey/vim-tmux-navigator", lazy = false },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", opts = { highlight = { enable = true }, ensure_installed = { "c", "lua", "vim", "python" }, auto_install = true }, config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end },
})

require("mason").setup()
if vim.lsp.enable then 
  vim.lsp.enable({"clangd", "lua_ls", "pyright"}) 
end
EOF
    print_success "Neovim configured."
}

main() {
    setup_path
    install_package nvim
    install_package tmux
    install_package starship
    setup_starship
    setup_tmux
    setup_neovim
    print_success "Setup Complete! PLEASE RESTART YOUR TERMINAL."
}

main "$@"
