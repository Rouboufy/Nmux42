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

    # 42 School specific check: install in goinfre if home is limited
    if [ -d "/goinfre/$USER" ] || [ -d "/sgoinfre/$USER" ]; then
        print_info "42 Environment detected. Attempting to install Homebrew in goinfre..."
        # Note: Standard brew install script doesn't love being moved, 
        # but we'll try the official way first.
    fi

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
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { theme = 'tokyonight' }
  },

  -- Completion
  {
    "saghen/blink.cmp",
    version = "*",
    opts = {
      keymap = { preset = "default" },
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

  -- Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = { accept = "<M-l>" },
        },
        panel = { enabled = false },
      })
    end,
  },

  { "neovim/nvim-lspconfig" },
  { "mason-org/mason.nvim" },
  { "tpope/vim-fugitive" },
  { "ojroques/nvim-osc52" },
  {
    "norcalli/nvim-colorizer.lua",
    config = function() require("colorizer").setup() end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep)
    end,
  },

  -- Tmux Navigator
  { "christoomey/vim-tmux-navigator", lazy = false },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      highlight = { enable = true },
      ensure_installed = { "c", "lua", "vim", "python", "typescript" },
      auto_install = true,
    },
    config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end,
  },
})

require("mason").setup()
if vim.lsp.enable then
  vim.lsp.enable({"clangd", "ts_ls", "lua_ls", "python"})
end
EOF
    print_success "Neovim configured."
}

# Main Execution
main() {
    print_info "Starting Setup for $MACHINE..."
    
    mkdir -p ~/.config ~/.local/bin ~/.tmux/plugins
    
    setup_path
    ensure_brew
    
    install_package nvim
    install_package tmux
    install_package starship
    
    setup_neovim
    
    print_success "Setup Complete! PLEASE RUN: source ~/.zshrc"
    print_info "Then run 'nvim' and wait for plugins to install."
}

main "$@"
