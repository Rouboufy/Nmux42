#!/bin/bash

# ========================================
# Nmux42 Update Script
# Performs git pull and re-runs setup
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

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

print_info "Updating Nmux42 repository..."
if git pull; then
    print_success "Repository updated successfully."
else
    print_error "Failed to pull latest changes from git."
    exit 1
fi

print_info "Running setup script to sync configurations..."
# We run setup.sh with the --update flag to skip redundant prompts
bash setup.sh --update

print_success "Update complete! Please restart Neovim to apply changes."
