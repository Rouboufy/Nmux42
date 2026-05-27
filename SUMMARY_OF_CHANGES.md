# Summary of Changes - May 27, 2026

This document summarizes the updates and configuration changes implemented for the Nmux42 project.

## 1. Japonette CLI Update
- Updated the `japonette` CLI tool to the latest version (**0.1.2**).
- Configured npm global prefix to `~/.npm-global` to allow global installations without sudo.
- Verified the tool's functionality and path integration.

## 2. Repository Security & Protection
- **Branch Protection**: Configured rules for the `main` branch to require Pull Requests and at least one approving review before merging.
- **Code Owners**: Created `.github/CODEOWNERS` to designate `@Rouboufy` and `@jsk-4970` as the mandatory reviewers for the codebase.
- **Self-Approval**: Adjusted protection settings to allow the repository owner to merge their own Pull Requests while still enforcing the PR workflow.

## 3. Open Source & Contribution Guidelines
- **CONTRIBUTING.md**: Created a new file outlining the development workflow, coding standards (42 Norm), and the review process for external contributors.
- **README.md**: Updated the main documentation with a "Contributing" section and updated status information.

## 4. Formatter Enhancements (42 Norm)
A significant overhaul of the C formatter was performed to ensure strict adherence to 42 school standards:
- **Local Module**: Implemented a fixed formatter in `nvim/lua/norm-format-fixed.lua` to override limitations in the external plugin.
- **Dynamic Header Detection**: The formatter now correctly detects the 42 header and preserves it, avoiding bugs in short files or files without headers.
- **Structural Fixes**:
    - **Declaration Splitting**: Automatically splits `int i = 0;` into `int i;` and `i = 0;`.
    - **Post-Declaration Newline**: Ensures an empty line exists between the variable declaration block and the subsequent code.
- **Improved Alignment**: Enhanced regex to handle multi-word types (`unsigned int`, `struct s_data`, etc.) and pointer alignment using tabs.

## 5. Branch Management
- **PR #1**: Created a Pull Request to promote the `dev` branch to `main`, including all recent features and fixes.
- **Version Bump**: Renamed the dev version to `0.0.2-nightly` to reflect the ongoing improvements.

## 6. Workspace Sync
- Successfully ran `./update.sh` and `setup.sh --update` multiple times to ensure the live Neovim and Tmux configurations match the repository state.
