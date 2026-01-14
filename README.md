# My 42 Development Environment

A complete, zero-config development setup for 42 school projects featuring Neovim and Tmux with custom configurations.

## 🚀 Quick Setup

### Option 1: Direct Installation
```bash
curl -sSL https://raw.githubusercontent.com/Rouboufy/config/main/setup.sh | bash
```

### Option 2: Clone and Run
```bash
git clone git@github.com:Rouboufy/config.git
cd config
./setup.sh
```

## 📋 What's Included

### Neovim Configuration
- **Color Scheme**: Ayu-dark theme
- **LSP**: Clangd for C/C++ development
- **Autocompletion**: nvim-cmp with snippets
- **42 Header**: Built-in 42 school header generator
- **OpenCode Integration**: AI coding assistant
- **Tree-sitter**: Syntax highlighting
- **NERDCommenter**: Easy commenting
- **Tmux Navigator**: Seamless pane navigation

### Tmux Configuration
- **Modern Status Bar**: Custom theme with 42 colors
- **Plugin Manager**: TPM with useful plugins
- **Key Bindings**: Vim-like navigation and window management
- **Mouse Support**: Click to select panes, resize with drag
- **Session Management**: Auto-restore sessions

### OpenCode Plugin
- **AI Assistant**: Integrated AI coding help
- **Context Aware**: Uses current buffer context
- **Quick Chat**: Fast access with `<leader>oc`
- **Custom Models**: Support for multiple AI models

## 🎯 Key Features

### For 42 Students
- **42 Headers**: Automatic 42 school headers with `:Stdheader` or `F1`
- **Project Templates**: Ready for 42 project structure
- **Coding Standards**: Enforced formatting and naming
- **Git Integration**: Seamless git workflow

### Productivity
- **Split Navigation**: Ctrl+h/j/k/l between tmux panes and nvim windows
- **LSP Support**: Code completion, diagnostics, and refactoring
- **Auto-completion**: Intelligent code suggestions
- **Session Management**: Save and restore tmux sessions

### Developer Experience
- **No Sudo Required**: Installs in user directories only
- **Zero Config**: Works out of the box
- **Cross-Platform**: Linux, macOS, WSL support
- **Plugin Management**: Automatic plugin installation and updates

## 🛠 Installation Details

The setup script:
- ✅ Installs in `~/.config/nvim` and `~/.tmux.conf`
- ✅ No system-wide changes (no sudo required)
- ✅ Downloads plugins automatically
- ✅ Creates necessary directories
- ✅ Configures key bindings and settings

## 📖 Usage Guide

### Tmux Commands
```bash
tmux                    # Start tmux
Ctrl-a r               # Reload config
Ctrl-a |               # Split vertical
Ctrl-a -               # Split horizontal
Ctrl-a h/j/k/l         # Navigate panes
Ctrl-a H/J/K/L         # Resize panes
Ctrl-a I               # Install plugins
```

### Neovim Commands
```bash
nvim                   # Start neovim
:Stdheader             # Insert 42 header (or F1)
:LspStart              # Start LSP
:OpenCodeInfo          # Show usage info
<leader>oc             # Open OpenCode assistant
<leader>pv             # Open file explorer
```

### OpenCode AI Assistant
```vim
# Configure API key
:lua vim.g.opencode_api_key = "your_key_here"

# Use AI assistant
<leader>oc             # Open assistant
# Type: quick_chat     # Chat with current context
# Type: help           # Show all commands
```

## 🎨 Customization

### 42 School Information
Edit in nvim:
```vim
:lua vim.g.user42 = 'your_username'
:lua vim.g.mail42 = 'your_email@student.42.fr'
```

### OpenCode Configuration
Set environment variable:
```bash
export OPENCODE_API_KEY="your_api_key_here"
```

### Tmux Theme
Edit `~/.tmux.conf` colors section (lines 90-120).

### Neovim Theme
Change theme in `~/.config/nvim/init.lua` (replace `neovim-ayu`).

## 🔧 Troubleshooting

### Tmux Plugins Not Working
```bash
# Install plugins manually
tmux source ~/.tmux.conf
Ctrl-a I
```

### OpenCode Not Working
1. Check plugin exists: `ls ~/.config/nvim/opencode.nvim`
2. Set API key: `export OPENCODE_API_KEY="your_key"`
3. Restart nvim

### LSP Not Working
1. Install clangd: `sudo apt install clangd` (Ubuntu/Debian)
2. Start manually: `:LspStart` or `<leader>lsp`
3. Check with: `:LspInfo`

### Permission Issues
Make setup script executable:
```bash
chmod +x setup.sh
```

## 📁 Repository Structure

```
.
├── setup.sh              # Main installation script
├── README.md              # This file
├── nvim/
│   └── init.lua          # Neovim configuration
├── tmux/
│   └── tmux.conf         # Tmux configuration
└── opencode.nvim/        # OpenCode plugin
    ├── lua/
    │   └── opencode/
    └── plugin/
```

## 🤝 Contributing

Feel free to:
- Report issues
- Suggest improvements
- Submit pull requests
- Share configurations

## 📄 License

MIT License - feel free to use and modify for your needs.

## 🙏 Acknowledgments

- **42 School**: For the coding standards and motivation
- **OpenCode Team**: For the AI assistant plugin
- **Neovim Community**: For the amazing plugins
- **Tmux Community**: For the powerful terminal multiplexer

---

**Happy Coding! 💻🚀**

Made with ❤️ for 42 students
