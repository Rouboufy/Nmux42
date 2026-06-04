#!/bin/bash

# ========================================
# Nmux42 Uninstaller Script
# Removes all Nmux42 isolated directories and optional dependencies
#
# Nmux42 installs to its own isolated paths:
#   Config:   ~/.config/nmux42/
#   Data:     ~/.local/share/nmux42/
#   State:    ~/.local/state/nmux42/
#   Cache:    ~/.cache/nmux42/
#   Launcher: ~/.local/bin/nmux
#
# This script cleans up legacy shell rc modifications,
# but does NOT touch ~/.config/nvim/ or ~/.config/tmux/.
# ========================================

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

# Main Menu
print_info "Nmux42 Uninstaller"
echo -e "1) ${RED}Full Uninstall${NC} (Remove all Nmux42 data)"
echo -e "2) Cancel"
read -p "Select an option [1-2]: " choice

case $choice in
    1)
        read -p "Are you sure you want to uninstall Nmux42? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            print_info "Uninstall cancelled."
            exit 0
        fi
        ;;
    *)
        print_info "Exiting."
        exit 0
        ;;
esac

# ----------------------------------------
# 1. Remove Nmux42 Isolated Directories
# ----------------------------------------
print_info "Removing Nmux42 configuration and data..."

# Config directory (nvim config + tmux config live here)
if [ -d "$HOME/.config/nmux42" ]; then
    rm -rf "$HOME/.config/nmux42"
    print_success "Removed ~/.config/nmux42/"
fi

# Data directory (plugins, mason, undo history)
if [ -d "$HOME/.local/share/nmux42" ]; then
    rm -rf "$HOME/.local/share/nmux42"
    print_success "Removed ~/.local/share/nmux42/"
fi

# State directory
if [ -d "$HOME/.local/state/nmux42" ]; then
    rm -rf "$HOME/.local/state/nmux42"
    print_success "Removed ~/.local/state/nmux42/"
fi

# Cache directory
if [ -d "$HOME/.cache/nmux42" ]; then
    rm -rf "$HOME/.cache/nmux42"
    print_success "Removed ~/.cache/nmux42/"
fi

# Launcher script
if [ -f "$HOME/.local/bin/nmux" ]; then
    rm -f "$HOME/.local/bin/nmux"
    print_success "Removed ~/.local/bin/nmux"
fi

# ----------------------------------------
# 2. Remove Optional User-space Binaries
# ----------------------------------------
print_info "Checking optional user-space binaries..."

if [ -f "$HOME/.local/bin/lazygit" ]; then
    read -p "Remove lazygit from ~/.local/bin/lazygit? (y/N): " remove_lazygit
    if [[ "$remove_lazygit" =~ ^[Yy]$ ]]; then
        rm -f "$HOME/.local/bin/lazygit"
        print_success "Removed ~/.local/bin/lazygit."
    fi
fi

if [ -f "$HOME/.local/bin/nvim" ] || [ -d "$HOME/.local/share/nvim-dist" ]; then
    read -p "Remove Neovim from ~/.local/bin/nvim and ~/.local/share/nvim-dist? (y/N): " remove_nvim
    if [[ "$remove_nvim" =~ ^[Yy]$ ]]; then
        rm -f "$HOME/.local/bin/nvim"
        rm -rf "$HOME/.local/share/nvim-dist"
        print_success "Removed Neovim binary and distribution."
    fi
fi

# ----------------------------------------
# 3. Remove Node.js / NVM / NPM Global
# ----------------------------------------
if [ -d "$HOME/.nvm" ]; then
    read -p "Remove NVM and all installed Node.js versions in ~/.nvm? (y/N): " remove_nvm
    if [[ "$remove_nvm" =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.nvm"
        print_success "Removed ~/.nvm."
    fi
fi

if [ -d "$HOME/.npm-global" ]; then
    read -p "Remove NPM global packages in ~/.npm-global? (y/N): " remove_npm
    if [[ "$remove_npm" =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.npm-global"
        print_success "Removed ~/.npm-global."
    fi
fi

# ----------------------------------------
# 4. Remove Local Homebrew (Linuxbrew)
# ----------------------------------------
if [ -d "$HOME/.linuxbrew" ]; then
    read -p "Remove locally installed Homebrew in ~/.linuxbrew? (y/N): " remove_brew
    if [[ "$remove_brew" =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.linuxbrew"
        print_success "Removed ~/.linuxbrew."
    fi
fi

# ----------------------------------------
# 5. Remove Fonts
# ----------------------------------------
print_info "Cleaning up fonts..."
if [ -d "$HOME/.local/share/fonts" ]; then
    find "$HOME/.local/share/fonts" -name "JetBrainsMono*" -delete
    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$HOME/.local/share/fonts" 2>/dev/null || true
    fi
    print_success "Removed JetBrainsMono Nerd Fonts."
fi

# ----------------------------------------
# 6. Cleanup Active Sessions & Configs
# ----------------------------------------
print_info "Cleaning up active sessions and configurations..."

# Kill running tmux sessions
if command -v tmux >/dev/null 2>&1; then
    if tmux has-session -t nmux42 2>/dev/null; then
        print_info "Killing running nmux42 tmux sessions..."
        # Kill any session starting with nmux42 (e.g., nmux42, nmux42-1)
        tmux list-sessions -F '#S' | grep '^nmux42' | xargs -I{} tmux kill-session -t {}
        print_success "Killed nmux42 tmux sessions."
    fi
    if tmux has-session -t main 2>/dev/null; then
        print_info "Killing legacy 'main' tmux session..."
        tmux kill-session -t main
        print_success "Killed 'main' tmux session."
    fi
fi

# Clean up legacy shell rc modifications
for rc_file in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [ -f "$rc_file" ] && grep -q "# --- Auto-launch tmux ---" "$rc_file"; then
        print_info "Found legacy Auto-launch tmux block in $rc_file."
        if [ -f "${rc_file}.bak" ]; then
            print_info "Restoring backup ${rc_file}.bak..."
            cp "${rc_file}.bak" "$rc_file"
            print_success "Restored $rc_file from backup."
        else
            print_warning "No ${rc_file}.bak found. Attempting to remove the block..."
            temp_rc=$(mktemp)
            sed '/# --- Auto-launch tmux ---/,/^fi$/d' "$rc_file" > "$temp_rc"
            mv "$temp_rc" "$rc_file"
            print_success "Removed Auto-launch tmux block from $rc_file."
        fi
    fi
done

# Revert npm config
if command -v npm >/dev/null 2>&1; then
    # Only if prefix was set to ~/.npm-global
    CURRENT_PREFIX=$(npm config get prefix)
    if [ "$CURRENT_PREFIX" = "$HOME/.npm-global" ]; then
        print_info "Reverting npm global prefix..."
        npm config delete prefix
        print_success "Reverted npm global prefix."
    fi
    
    # Revert strict-ssl if it was false
    CURRENT_SSL=$(npm config get strict-ssl)
    if [ "$CURRENT_SSL" = "false" ]; then
        print_info "Reverting npm strict-ssl setting..."
        npm config delete strict-ssl
        print_success "Reverted npm strict-ssl."
    fi
fi

# ----------------------------------------
# 7. Final Summary
# ----------------------------------------
print_info "--- Uninstall Complete ---"
print_warning "Note: System packages installed via pacman/apt/dnf/brew were NOT removed."
print_success "Nmux42 has been removed. Please restart your terminal."
