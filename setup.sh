#!/bin/bash

# ========================================
# Neovim & Tmux Setup Script
# Author: blanglai
# Description: Install and configure nvim and tmux with custom settings
# Usage: curl -sSL https://your-repo/setup.sh | bash
# Or: git clone https://your-repo && cd your-repo && ./setup.sh
# ========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create directories
setup_directories() {
    print_info "Creating necessary directories..."
    
    mkdir -p ~/.config/nvim
    mkdir -p ~/.local/share/nvim
    mkdir -p ~/.local/state/nvim
    mkdir -p ~/.cache/nvim
    mkdir -p ~/.tmux/plugins
    
    print_success "Directories created"
}

# Install dependencies
install_dependencies() {
    print_info "Checking dependencies..."
    
    # Check for git
    if ! command_exists git; then
        print_error "Git is required but not installed"
        exit 1
    fi
    
    # Check for curl (optional, used for some features)
    if ! command_exists curl; then
        print_warning "Curl not found - some features may not work"
    fi
    
    # Check for node (optional, for LSP features)
    if ! command_exists node; then
        print_warning "Node.js not found - some LSP features may not work"
    fi
    
    print_success "Dependencies checked"
}

# Install Neovim (if not present)
install_neovim() {
    if ! command_exists nvim; then
        print_info "Installing Neovim..."
        
        if command_exists apt-get; then
            # Ubuntu/Debian
            sudo apt-get update
            sudo apt-get install -y neovim
        elif command_exists yum; then
            # CentOS/RHEL
            sudo yum install -y neovim
        elif command_exists dnf; then
            # Fedora
            sudo dnf install -y neovim
        elif command_exists pacman; then
            # Arch Linux
            sudo pacman -S --noconfirm neovim
        elif command_exists brew; then
            # macOS
            brew install neovim
        else
            print_error "Package manager not detected. Please install Neovim manually."
            exit 1
        fi
    else
        print_success "Neovim is already installed"
    fi
}

# Install Tmux (if not present)
install_tmux() {
    if ! command_exists tmux; then
        print_info "Installing Tmux..."
        
        if command_exists apt-get; then
            sudo apt-get install -y tmux
        elif command_exists yum; then
            sudo yum install -y tmux
        elif command_exists dnf; then
            sudo dnf install -y tmux
        elif command_exists pacman; then
            sudo pacman -S --noconfirm tmux
        elif command_exists brew; then
            brew install tmux
        else
            print_error "Package manager not detected. Please install Tmux manually."
            exit 1
        fi
    else
        print_success "Tmux is already installed"
    fi
}

# Setup tmux configuration
setup_tmux() {
    print_info "Setting up tmux configuration..."
    
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
set -g default-shell /bin/bash
set -g default-command /bin/bash

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

    print_success "Tmux configuration installed"
}

# Clone OpenCode plugin
clone_opencode() {
    print_info "Cloning OpenCode plugin..."
    
    # Remove existing opencode directory if it exists
    if [ -d ~/.config/nvim/opencode.nvim ]; then
        rm -rf ~/.config/nvim/opencode.nvim
    fi
    
    # Clone the OpenCode plugin
    git clone https://github.com/your-opencode-repo/opencode.nvim.git ~/.config/nvim/opencode.nvim 2>/dev/null || {
        print_warning "OpenCode plugin not found at expected URL. You'll need to add it manually."
        mkdir -p ~/.config/nvim/opencode.nvim
        echo "# OpenCode plugin directory - add your plugin here" > ~/.config/nvim/opencode.nvim/README.md
    }
    
    print_success "OpenCode plugin cloned"
}

# Setup Neovim configuration
setup_neovim() {
    print_info "Setting up Neovim configuration..."
    
    clone_opencode
    clone_42header
    
    cat > ~/.config/nvim/init.lua << 'EOF'
vim.g.mapleader = ' '
vim.g.localleader = ' '
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)
vim.keymap.set('n', '<leader>wq', vim.cmd.wq)
vim.opt.relativenumber = true
vim.opt.nu = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.colorcolumn = '80'

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
  {
    "Shatur/neovim-ayu",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("ayu-dark")
    end,
  },
  {
    dir = vim.fn.expand("~/.config/nvim/opencode.nvim"),
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("opencode").setup({
        api_key = os.getenv("OPENCODE_API_KEY") or "your_api_key_here",
        quick_chat = {
          default_model = "big-pickle",
        },
      })
      vim.keymap.set('n', '<leader>oc', ':Opencode<CR>', { desc = "Open OpenCode" })
      vim.keymap.set('v', '<leader>oc', ':Opencode<CR>', { desc = "Open OpenCode with selection" })
    end,
  },
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
  {
    "preservim/nerdcommenter",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        configs.setup({
          ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
          highlight = { enable = true },
          indent = { enable = true },
        })
      end
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      
      cmp.setup({
        snippet = {
          expand = function(args)
            -- For future snippet plugin integration
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'vsnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      local function on_attach(client, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "h", "hpp" },
        callback = function(args)
          local bufnr = args.buf
          vim.schedule(function()
            if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
              vim.lsp.start({
                name = "clangd",
                cmd = { "clangd", "--background-index" },
                root_dir = vim.fn.getcwd,
                on_attach = on_attach,
         capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
              })
            end
          end)
        end,
      })

      vim.api.nvim_create_user_command("LspStart", function()
        local bufnr = vim.api.nvim_get_current_buf()
        if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
          vim.lsp.start({
            name = "clangd",
            cmd = { "clangd", "--background-index" },
            root_dir = vim.fn.getcwd,
            on_attach = on_attach,
                  capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
          })
          print("Clangd LSP started")
        else
          print("Clangd LSP already running")
        end
      end, {})
    end,
  },
})

vim.keymap.set('n', '<leader>lsp', function()
  local bufnr = vim.api.nvim_get_current_buf()
  if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
    vim.lsp.start({
      name = "clangd",
      cmd = { "clangd", "--background-index", "--std=c11" },
      root_dir = vim.fn.getcwd,
      on_attach = function(client, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
      end,
    })
    print("LSP started")
  else
    print("LSP already running")
  end
end, { desc = "Start LSP manually" })

-- 42 Header Plugin (built-in, no external dependencies)
local function insert_42_header()
  local filename = vim.fn.expand("%:t")
  local user = vim.g.user42 or 'your_username'
  local mail = vim.g.mail42 or 'your_email@student.42.fr'
  local date = os.date("%Y/%m/%d %H:%M:%S")
  
  local header = {
    "/* ************************************************************************** */",
    "/*                                                                            */",
    "/*                                                        :::      ::::::::   */",
    "/*   " .. filename .. string.rep(" ", 46 - #filename) .. " :+:      :+:    :+:   */",
    "/*                                                    +:+ +:+         +:+     */",
    "/*   By: " .. user .. " <" .. mail .. ">          +#+  +:+       +#+        */",
    "/*                                                +#+#+#+#+#+   +#+           */",
    "/*   Created: " .. date .. " by " .. user .. "          #+#    #+#             */",
    "/*   Updated: " .. date .. " by " .. user .. "         ###   ########.fr       */",
    "/*                                                                            */",
    "/* ************************************************************************** */",
    ""
  }
  
  -- Insert at the beginning of the file
  vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
  print("42 header inserted!")
end

-- Create command and keymap
vim.api.nvim_create_user_command("Stdheader", insert_42_header, { desc = "Insert 42 header" })
vim.keymap.set('n', '<F1>', insert_42_header, { desc = "Insert 42 header" })

-- Set default values (can be overridden)
vim.g.user42 = vim.g.user42 or 'your_username'
vim.g.mail42 = vim.g.mail42 or 'your_email@student.42.fr'

-- OpenCode info
vim.api.nvim_create_user_command("OpenCodeInfo", function()
  print("OpenCode Usage:")
  print("  <leader>oc - Open Opencode interface")
  print("  Then type: quick_chat (for chat with current context)")
  print("  Or type: help (to see all commands)")
  print("")
  print("Available Opencode commands:")
  print("  quick_chat - Chat with current buffer/selection")
  print("  new - Create new session")
  print("  sessions - Select existing session")
  print("  models - Switch provider/model")
  print("  help - Show full help")
  print("")
  print("42 Header:")
  print("  :Stdheader - Insert 42 school header")
  print("  <F1> - Insert 42 school header")
  print("  vim.g.user42 = 'your_username' (to set your name)")
  print("  vim.g.mail42 = 'your_email@student.42.fr' (to set your email)")
  print("")
  print("NERDCommenter:")
  print("  <leader>cc - Comment line")
  print("  <leader>cu - Uncomment line")
  print("  <leader>c<space> - Toggle comment")
  print("")
  print("Tmux Navigator:")
  print("  Ctrl+h/j/k/l - Navigate between tmux panes and nvim windows")
end, { desc = "Show usage info" })
EOF

    print_success "Neovim configuration installed"
}

# Install TPM (Tmux Plugin Manager) plugins
install_tmux_plugins() {
    print_info "Installing tmux plugins..."
    
    # Check if TPM exists
    if [ ! -d ~/.tmux/plugins/tpm ]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
    
    # Install plugins
    if [ -f ~/.tmux/plugins/tpm/bin/install_plugins ]; then
        ~/.tmux/plugins/tpm/bin/install_plugins
        print_success "Tmux plugins installed"
    else
        print_warning "TPM not properly installed - tmux plugins may need manual installation"
    fi
}

# Create usage info
create_info() {
    print_info "Creating usage information..."
    
    cat > ~/.config/nvim/SETUP_INFO.md << 'EOF'
# Development Environment Setup

## Installation Complete! 🎉

### Tmux
- Start: `tmux`
- Prefix: `Ctrl-a` (instead of Ctrl-b)
- Reload config: `Ctrl-a r`
- Split vertical: `Ctrl-a |`
- Split horizontal: `Ctrl-a -`
- Navigate: `Ctrl-a h/j/k/l`
- Resize: `Ctrl-a H/J/K/L`

### Neovim
- Start: `nvim`
- 42 Header: `:Stdheader` or `F1`
- LSP Start: `:LspStart` or `<leader>lsp`
- OpenCode: `<leader>oc`
- Show Info: `:OpenCodeInfo`
- Explorer: `<leader>pv`
- Quit/Save: `<leader>wq`

### Plugin Management
- Tmux plugins: `Ctrl-a I` (install), `Ctrl-a U` (update)
- Neovim plugins: `:Lazy`

### Customization
- Edit your 42 info in nvim: `:lua vim.g.user42 = 'your_username'`
- Edit your email: `:lua vim.g.mail42 = 'your_email@student.42.fr'`

### OpenCode Configuration
- Set your API key: `export OPENCODE_API_KEY="your_key_here"`
- Or add to your shell rc file

### Issues?
1. Tmux plugins not working: Press `Ctrl-a I` to install
2. OpenCode not working: Check that opencode.nvim is in ~/.config/nvim/
3. LSP not working: Run `:LspStart` or install clangd

Happy coding! 💻
EOF

    print_success "Usage information created"
}

# Main setup function
main() {
    print_info "Starting development environment setup..."
    
    setup_directories
    install_dependencies
    
    # Skip installs if tools already exist (no sudo needed)
    if command_exists nvim; then
        print_success "Neovim is available - skipping install"
    else
        print_warning "Neovim not found - please install it manually or run with sudo"
    fi
    
    if command_exists tmux; then
        print_success "Tmux is available - skipping install"
    else
        print_warning "Tmux not found - please install it manually or run with sudo"
    fi
    
    setup_tmux
    setup_neovim
    install_tmux_plugins
    create_info
    
    print_success "Setup complete!"
    
    echo
    echo "🎉 Development environment is ready!"
    echo
    echo "Quick start:"
    echo "  tmux    # Start tmux"
    echo "  nvim    # Start neovim"
    echo "  cat ~/.config/nvim/SETUP_INFO.md    # Read setup info"
    echo
    echo "Don't forget to:"
    echo "  1. Set your 42 credentials in nvim"
    echo "  2. Configure OpenCode API key"
    echo "  3. Press Ctrl-a I in tmux to install plugins"
}

# Clone 42Header plugin
clone_42header() {
    print_info "Cloning official 42Header plugin..."
    
    # Remove existing 42header directory if it exists
    if [ -d ~/.config/nvim/pack/plugins/start/42header ]; then
        rm -rf ~/.config/nvim/pack/plugins/start/42header
    fi
    
    # Create pack directory structure
    mkdir -p ~/.config/nvim/pack/plugins/start
    
    # Copy 42Header plugin from current directory
    if [ -d 42header ]; then
        cp -r 42header ~/.config/nvim/pack/plugins/start/
        print_success "42Header plugin installed from local directory"
    else
        git clone https://github.com/42Paris/42header.git ~/.config/nvim/pack/plugins/start/42header 2>/dev/null || {
            print_warning "42Header plugin not found. Creating placeholder..."
            mkdir -p ~/.config/nvim/pack/plugins/start/42header
            echo "# 42Header plugin directory" > ~/.config/nvim/pack/plugins/start/42header/README.md
        }
    fi
    
    print_success "42Header plugin cloned"
}

# Run main function
main "$@"