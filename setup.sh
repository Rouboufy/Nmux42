#!/bin/bash

# ========================================
# Nmux42 Setup Script (Isolated App)
# Version: see VERSION file
# Author: Rouboufy
# Installs to ~/.config/nmux42/ (does NOT
# modify ~/.config/nvim, ~/.zshrc, etc.)
# ========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION=$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null || echo "0.0.1")

# Parse arguments
IS_UPDATE=false
for arg in "$@"; do
    if [ "$arg" = "--update" ]; then
        IS_UPDATE=true
    fi
done

# Cleanup temporary download files on script exit/failure
trap 'rm -rf "$SCRIPT_DIR/nvim.appimage" "$SCRIPT_DIR/squashfs-root" 2>/dev/null || true' EXIT

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
if [ -f /etc/arch-release ]; then
    IS_ARCH=true
fi

# Check for Sudo/Root Rights
has_sudo() {
    [ "$EUID" -eq 0 ] || { command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; }
}

# Homebrew Helper to Load Environment
load_brew() {
    if [ "$OS" = "Linux" ]; then
        if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
            eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
        fi
    else
        if [ -x "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -x "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
}

# Homebrew Fallback
ensure_brew() {
    if command_exists brew; then
        load_brew
        return
    fi
    print_info "Homebrew not found. Installing locally in home directory (no sudo)..."
    if [ "$OS" = "Linux" ]; then
        if [ ! -d "$HOME/.linuxbrew/Homebrew" ]; then
            git clone https://github.com/Homebrew/brew "$HOME/.linuxbrew/Homebrew"
        fi
        mkdir -p "$HOME/.linuxbrew/bin"
        ln -sf "$HOME/.linuxbrew/Homebrew/bin/brew" "$HOME/.linuxbrew/bin/brew"
    else
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    load_brew
}

# Configure user-space npm global installs (no sudo required)
setup_npm_prefix() {
    if command_exists npm; then
        print_info "Configuring npm to install packages locally in $HOME/.npm-global (no sudo)..."
        mkdir -p "$HOME/.npm-global"
        npm config set prefix "$HOME/.npm-global"
        # Bypass SSL proxy validation on 42 school network
        npm config set strict-ssl false
        # Export prefix path for the current installer session
        export PATH="$HOME/.npm-global/bin:$PATH"
    fi
}

# Check if Node.js version is >= 14 (needed for nullish coalescing '??' operator used by japonette)
is_node_version_ok() {
    local node_bin
    node_bin="$(command -v node 2>/dev/null || command -v nodejs 2>/dev/null)"
    if [ -z "$node_bin" ]; then
        return 1
    fi
    local major
    major=$("$node_bin" -e 'process.stdout.write(process.versions.node.split(".")[0])' 2>/dev/null)
    if [ -n "$major" ] && [ "$major" -ge 14 ]; then
        return 0
    fi
    return 1
}

# Install or switch to a modern Node.js (>= 14) via nvm (fully passwordless, no sudo)
ensure_modern_node() {
    if is_node_version_ok; then
        print_success "Node.js version is >= 14. No upgrade needed."
        return
    fi

    local node_ver
    node_ver=$(node --version 2>/dev/null || nodejs --version 2>/dev/null || echo "none")
    print_warning "Node.js version ($node_ver) is too old for japonette (requires >= 14 for '??' operator)."
    print_info "Installing Node.js LTS via nvm (no sudo needed)..."

    # Install nvm if not already present
    if [ ! -d "$HOME/.nvm" ]; then
        print_info "Downloading nvm..."
        curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh -o /tmp/nvm_install.sh
        # Run install without modifying shell rc files
        PROFILE=/dev/null bash /tmp/nvm_install.sh
        rm -f /tmp/nvm_install.sh
    fi

    # Load nvm for this shell session
    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

    if ! command_exists nvm; then
        print_error "nvm failed to load. Please install Node.js >= 14 manually."
        return 1
    fi

    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'
    print_success "Node.js LTS installed and active via nvm: $(node --version)"
}

# Check if Neovim version is at least 0.11.0
is_nvim_version_ok() {
    if ! command_exists nvim; then
        return 1
    fi
    local version_str
    version_str="$(nvim --version | head -n 1)"
    local major minor
    major=$(echo "$version_str" | grep -oE 'v[0-9]+\.[0-9]+' | cut -d'.' -f1 | tr -d 'v')
    minor=$(echo "$version_str" | grep -oE 'v[0-9]+\.[0-9]+' | cut -d'.' -f2)
    
    if [ -n "$major" ] && [ -n "$minor" ]; then
        if [ "$major" -gt 0 ] || { [ "$major" -eq 0 ] && [ "$minor" -ge 11 ]; }; then
            return 0
        fi
    fi
    return 1
}

# Install or upgrade to Neovim 0.11.0+ (nightly)
install_proper_neovim() {
    print_info "Checking Neovim version..."
    if is_nvim_version_ok; then
        print_success "Neovim version is correct ($(nvim --version | head -n 1))."
        return
    fi

    if command_exists nvim; then
        print_warning "Installed Neovim version is older than v0.11.0. Upgrading..."
    fi

    if [ "$OS" = "Linux" ]; then
        print_info "Downloading Neovim Nightly AppImage for Linux..."
        mkdir -p "$HOME/.local/bin"
        curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
        chmod +x nvim.appimage
        
        # Test if it runs natively (requires FUSE)
        if ./nvim.appimage --version >/dev/null 2>&1; then
            mv nvim.appimage "$HOME/.local/bin/nvim"
            print_success "Neovim Nightly AppImage installed to ~/.local/bin/nvim."
        else
            print_warning "FUSE not available to run AppImage. Extracting AppImage..."
            ./nvim.appimage --appimage-extract >/dev/null
            mkdir -p "$HOME/.local/share/nvim-dist"
            rm -rf "$HOME/.local/share/nvim-dist/squashfs-root"
            mv squashfs-root "$HOME/.local/share/nvim-dist/"
            ln -sf "$HOME/.local/share/nvim-dist/squashfs-root/usr/bin/nvim" "$HOME/.local/bin/nvim"
            rm -f nvim.appimage
            print_success "Neovim Nightly extracted and linked to ~/.local/bin/nvim."
        fi
    else
        # macOS
        print_info "Installing Neovim Nightly via Homebrew..."
        ensure_brew
        load_brew
        brew uninstall --force neovim 2>/dev/null || true
        brew install neovim --HEAD
        print_success "Neovim Nightly installed."
    fi
}

# State variable to run apt-get update only once
APT_UPDATED=false

# Smart Package Installer supporting multiple package managers
install_package() {
    PACKAGE=$1
    ALT_NAME=$2 # For cases like nodejs vs node
    
    if command_exists "$PACKAGE" || ([ -n "$ALT_NAME" ] && command_exists "$ALT_NAME"); then
        print_success "$PACKAGE is already installed."
        return
    fi

    # Try native package manager if sudo/root is available
    if has_sudo; then
        if [ "$IS_ARCH" = true ] && command_exists pacman; then
            print_info "Arch detected with sudo rights: Installing $PACKAGE via pacman..."
            if [ "$EUID" -eq 0 ]; then
                pacman -S --noconfirm "$PACKAGE"
            else
                sudo pacman -S --noconfirm "$PACKAGE"
            fi
            return
        elif command_exists apt-get; then
            print_info "Debian/Ubuntu detected: Installing $PACKAGE via apt-get..."
            # Map packages for apt compatibility
            local apt_package="$PACKAGE"
            case "$PACKAGE" in
                nvim) apt_package="neovim" ;;
                python) apt_package="python3" ;;
                go) apt_package="golang" ;;
            esac
            
            if [ "$APT_UPDATED" = false ]; then
                print_info "Updating apt package index..."
                if [ "$EUID" -eq 0 ]; then
                    apt-get update -y
                else
                    sudo apt-get update -y
                fi
                APT_UPDATED=true
            fi
            
            if [ "$EUID" -eq 0 ]; then
                apt-get install -y "$apt_package"
            else
                sudo apt-get install -y "$apt_package"
            fi
            return
        elif command_exists dnf; then
            print_info "Fedora/RHEL detected: Installing $PACKAGE via dnf..."
            # Map packages for dnf compatibility
            local dnf_package="$PACKAGE"
            case "$PACKAGE" in
                nvim) dnf_package="neovim" ;;
                python) dnf_package="python3" ;;
            esac
            
            if [ "$EUID" -eq 0 ]; then
                dnf install -y "$dnf_package"
            else
                sudo dnf install -y "$dnf_package"
            fi
            return
        fi
    fi

    # Fallback to Homebrew (e.g. if no native manager or no sudo rights)
    print_info "No native manager with sudo rights found or supported. Installing $PACKAGE via Homebrew..."
    ensure_brew
    load_brew
    
    # Map packages for Homebrew compatibility
    local brew_package="$PACKAGE"
    if [ "$PACKAGE" = "clang" ]; then
        brew_package="llvm"
    elif [ "$PACKAGE" = "python" ]; then
        brew_package="python3"
    fi
    
    brew install "$brew_package"
}

# Ask User for Extras
ask_optional() {
    print_info "--- Optional Packages ---"

    # lazygit check
    if command_exists lazygit; then
        print_success "lazygit is already installed (passing)."
    else
        if [ "$IS_UPDATE" = true ]; then
            print_info "Skipping lazygit installation (not found during update)."
        else
            read -p "Install lazygit (full-screen TUI git client, used by <leader>gg in Neovim)? (y/N): " install_lg
            if [[ "$install_lg" =~ ^[Yy]$ ]]; then
                print_info "Installing lazygit (static binary, no sudo)..."
                local LG_VERSION
                LG_VERSION=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
                    | grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')
                if [ -n "$LG_VERSION" ]; then
                    local LG_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LG_VERSION}/lazygit_${LG_VERSION}_Linux_x86_64.tar.gz"
                    mkdir -p "$HOME/.local/bin"
                    curl -fsSL "$LG_URL" | tar -xz -C /tmp lazygit
                    mv /tmp/lazygit "$HOME/.local/bin/lazygit"
                    chmod +x "$HOME/.local/bin/lazygit"
                    print_success "lazygit v${LG_VERSION} installed to ~/.local/bin/lazygit."
                else
                    print_warning "Could not determine latest lazygit version. Check: https://github.com/jesseduffield/lazygit/releases"
                fi
            fi
        fi
    fi

    # Zig check
    if command_exists zig; then
        print_success "Zig is already installed (passing)."
    else
        if [ "$IS_UPDATE" = true ]; then
            print_info "Skipping Zig installation (not found during update)."
        else
            read -p "Install Zig? (y/N): " install_zig
            if [[ "$install_zig" =~ ^[Yy]$ ]]; then
                install_package zig
            fi
        fi
    fi

    # Node stack check
    local has_node=false
    if command_exists node || command_exists nodejs; then
        has_node=true
        # Check version is modern enough
        if ! is_node_version_ok; then
            local cur_ver
            cur_ver=$(node --version 2>/dev/null || nodejs --version 2>/dev/null)
            print_warning "Node.js $cur_ver is installed but too old (japonette requires >= 14)."
            if [ "$IS_UPDATE" = true ]; then
                print_info "Updating Node.js to LTS via nvm automatically..."
                ensure_modern_node
            else
                read -p "Upgrade Node.js to LTS via nvm? (y/N): " upgrade_node
                if [[ "$upgrade_node" =~ ^[Yy]$ ]]; then
                    ensure_modern_node
                fi
            fi
        fi
        
        if command_exists tsc; then
            print_success "Node.js stack (Node, TS) is ready."
        else
            if [ "$IS_UPDATE" = true ]; then
                print_info "Skipping TypeScript installation (not found during update)."
            else
                print_info "Node.js is installed, but TypeScript is missing."
                read -p "Install TypeScript globally? (y/N): " install_ts
                if [[ "$install_ts" =~ ^[Yy]$ ]]; then
                    setup_npm_prefix
                    if command_exists npm; then
                        print_info "Installing TypeScript globally..."
                        npm install -g typescript
                    fi
                fi
            fi
        fi
    else
        if [ "$IS_UPDATE" = true ]; then
            print_info "Skipping Node.js stack installation (not found during update)."
        else
            read -p "Install Node.js stack (Node, TS, JS)? (y/N): " install_node
            if [[ "$install_node" =~ ^[Yy]$ ]]; then
                ensure_modern_node
                setup_npm_prefix
                if command_exists npm; then
                    print_info "Installing TypeScript globally..."
                    npm install -g typescript
                fi
                has_node=true
            fi
        fi
    fi

    # japonette check
    if command_exists japonette; then
        print_success "japonette CLI is already installed (passing)."
    else
        if [ "$IS_UPDATE" = true ]; then
            print_info "Skipping japonette installation (not found during update)."
        else
            read -p "Install japonette (42 intra CLI tool)? (y/N): " install_japonette
            if [[ "$install_japonette" =~ ^[Yy]$ ]]; then
                if ! is_node_version_ok; then
                    ensure_modern_node
                elif [ "$has_node" = false ]; then
                    ensure_modern_node
                fi
                setup_npm_prefix
                if command_exists npm; then
                    print_info "Installing japonette CLI globally..."
                    npm install -g japonette
                fi
            fi
        fi
    fi
}

install_launcher() {
    print_info "Installing nmux launcher..."
    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/nmux" << 'LAUNCHER'
#!/bin/bash
# ========================================
# Nmux42 — Isolated Development Environment
# Launcher script — runs Neovim with its own
# config, isolated from ~/.config/nvim
# ========================================

export NVIM_APPNAME="nmux42"
NMUX_TMUX_CONF="$HOME/.config/nmux42/tmux/tmux.conf"

# --no-tmux flag: skip tmux wrapper
if [ "$1" = "--no-tmux" ]; then
    shift
    exec nvim "$@"
fi

# If already inside tmux, just launch nvim
if [ -n "$TMUX" ]; then
    exec nvim "$@"
fi

# Otherwise, launch nvim inside tmux with our isolated config
if tmux has-session -t nmux42 2>/dev/null && [ "$(tmux list-clients -t nmux42 2>/dev/null | wc -l)" -gt 0 ]; then
    # Session exists and is occupied, create an independent session
    if [ $# -eq 0 ]; then
        exec tmux -f "$NMUX_TMUX_CONF" new-session "NVIM_APPNAME=nmux42 nvim"
    else
        exec tmux -f "$NMUX_TMUX_CONF" new-session "NVIM_APPNAME=nmux42 nvim $*"
    fi
else
    # Create or attach to the primary nmux42 session
    if [ $# -eq 0 ]; then
        exec tmux -f "$NMUX_TMUX_CONF" new-session -A -s nmux42 "NVIM_APPNAME=nmux42 nvim"
    else
        exec tmux -f "$NMUX_TMUX_CONF" new-session -A -s nmux42 "NVIM_APPNAME=nmux42 nvim $*"
    fi
fi
LAUNCHER
    chmod +x "$HOME/.local/bin/nmux"
    print_success "nmux launcher installed to ~/.local/bin/nmux."
    
    # Ensure ~/.local/bin is in PATH
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        print_warning "~/.local/bin is not in your PATH."
        print_info "Add this to your shell config: export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

setup_tmux() {
    print_info "Configuring Tmux (isolated in ~/.config/nmux42/tmux/)..."
    mkdir -p "$HOME/.config/nmux42/tmux"
    cp "$SCRIPT_DIR/tmux.conf" "$HOME/.config/nmux42/tmux/tmux.conf"
    cp "$SCRIPT_DIR/tmux-theme.sh" "$HOME/.config/nmux42/tmux/tmux-theme.sh"
    chmod +x "$HOME/.config/nmux42/tmux/tmux-theme.sh"
    bash "$HOME/.config/nmux42/tmux/tmux-theme.sh" 2>/dev/null || true
    print_success "Tmux configured."
}

setup_neovim() {
    print_info "Configuring Neovim (isolated in ~/.config/nmux42/)..."
    mkdir -p "$HOME/.config/nmux42"
    # Remove old nmux42 config if exists (clean re-deploy)
    if [ -d "$HOME/.config/nmux42" ]; then
        rm -rf "$HOME/.config/nmux42/lua" "$HOME/.config/nmux42/plugin" "$HOME/.config/nmux42/after" "$HOME/.config/nmux42/queries" "$HOME/.config/nmux42/init.lua" 2>/dev/null || true
    fi
    # Copy nvim config files into the isolated directory
    cp -r "$SCRIPT_DIR/nvim/"* "$HOME/.config/nmux42/"
    
    # Record the repository path for the Update feature
    mkdir -p "$HOME/.config/nmux42/lua/config"
    echo "return { path = \"$SCRIPT_DIR\", version = \"$VERSION\" }" > "$HOME/.config/nmux42/lua/config/repo_info.lua"
    
    print_success "Neovim configured (isolated as NVIM_APPNAME=nmux42)."
}

# Install JetBrainsMono Nerd Font (user-space, no sudo)
install_nerd_font() {
    local FONT_NAME="JetBrainsMono"
    local FONT_DIR="$HOME/.local/share/fonts"
    # Check if the font is already installed
    if fc-list 2>/dev/null | grep -qi "JetBrainsMono" 2>/dev/null; then
        print_success "JetBrainsMono Nerd Font already installed."
        return
    fi
    print_info "Installing JetBrainsMono Nerd Font (required for icons in Neovim/tmux)..."
    mkdir -p "$FONT_DIR"
    local VERSION="v3.2.1"
    local BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${VERSION}/JetBrainsMono.zip"
    local TMP_ZIP="/tmp/JetBrainsMono.zip"
    if curl -fsSL "$BASE_URL" -o "$TMP_ZIP"; then
        if command_exists unzip; then
            unzip -o -q "$TMP_ZIP" '*.ttf' -d "$FONT_DIR/"
            rm -f "$TMP_ZIP"
            # Refresh font cache (no sudo needed)
            if command_exists fc-cache; then
                fc-cache -f "$FONT_DIR" 2>/dev/null || true
            fi
            print_success "JetBrainsMono Nerd Font installed to $FONT_DIR."
            print_info "NOTE: Set your terminal emulator font to 'JetBrainsMono Nerd Font' for icons to display correctly."
        else
            print_warning "'unzip' not found. Please install it and run: unzip $TMP_ZIP -d $FONT_DIR/"
        fi
    else
        print_warning "Failed to download Nerd Font. Install manually from:"
        print_warning "https://github.com/ryanoasis/nerd-fonts/releases/latest"
    fi
}

cleanup_installation_temp() {
    print_info "Cleaning up temporary installation files and caches..."
    # Clean up Homebrew cache if brew is installed
    if command_exists brew; then
        print_info "Cleaning up Homebrew cache..."
        brew cleanup -s --prune=all || true
        rm -rf "$HOME/.cache/Homebrew" || true
    fi
    
    # Clean up npm cache if npm is installed
    if command_exists npm; then
        print_info "Cleaning up npm cache..."
        npm cache clean --force || true
    fi
    
    # Remove any stray AppImage or extracted directories in script directory
    rm -f "$SCRIPT_DIR/nvim.appimage" || true
    rm -rf "$SCRIPT_DIR/squashfs-root" || true
    
    print_success "Cleanup complete."
}

main() {
    print_info "Starting Comprehensive Setup (Nmux42 v$VERSION)..."
    
    # Ensure scripts are executable
    chmod +x "$SCRIPT_DIR/update.sh" 2>/dev/null || true
    chmod +x "$SCRIPT_DIR/uninstall.sh" 2>/dev/null || true
    
    # Essential Tools
    install_proper_neovim
    install_package tmux
    install_package git
    install_package curl
    
    # Search Tools
    install_package ripgrep rg
    if ! command_exists fd && ! command_exists fdfind; then
        if [ "$IS_ARCH" = true ] && command_exists pacman && has_sudo; then
            install_package fd
        elif command_exists apt-get && has_sudo; then
            install_package fd-find
        elif command_exists dnf && has_sudo; then
            install_package fd-find
        else
            install_package fd
        fi
    fi
    
    # Compilers & Runtimes
    install_package gcc
    install_package clang
    install_package python
    install_package go
    
    # Optional Packages
    ask_optional
    
    # Configurations
    install_launcher
    setup_tmux
    setup_neovim
    install_nerd_font
    
    # Cleanup temporary installation files & caches
    cleanup_installation_temp

    if [ "$IS_UPDATE" = true ]; then
        if [ -n "$NVIM" ]; then
            print_info "Update successful. Please use the reload prompt in Neovim to apply changes."
        else
            print_success "Update Complete! Run 'nmux' to start."
        fi
    else
        print_success "Setup Complete! Run 'nmux' to start your development environment."
        print_info "Make sure ~/.local/bin is in your PATH."
    fi
}

main "$@"
