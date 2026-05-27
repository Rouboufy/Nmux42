# Contributing to Nmux42

Thank you for your interest in contributing to Nmux42! We welcome contributions from the community, whether they are bug fixes, new features, or documentation improvements.

To maintain the quality and consistency of the project, please follow these guidelines:

## Development Workflow

1.  **Fork the Repository**: Create your own fork of the project on GitHub.
2.  **Clone your Fork**: `git clone https://github.com/YOUR_USERNAME/Nmux42.git`
3.  **Create a Branch**: Always branch off from the `dev` branch for your changes.
    *   `git checkout dev`
    *   `git pull origin dev`
    *   `git checkout -b feat/your-feature-name`
4.  **Implement Changes**: Make your changes, following the [Coding Standards](#coding-standards).
5.  **Commit & Push**: Commit your changes with clear, descriptive messages and push them to your fork.
6.  **Open a Pull Request**: Submit a Pull Request (PR) from your fork's feature branch to the **`dev`** branch of the main repository.

## Coding Standards

*   **42 Norm**: This project adheres to the 42 school coding standards for C files. Please ensure your code passes `norminette`.
*   **Neovim Configuration**: Follow the existing structure in `nvim/`. Use Lua for configuration and plugins.
*   **Documentation**: Update `README.md` or other documentation if your changes introduce new features or change existing behavior.

## Review Process

*   All contributions must be submitted via a Pull Request.
*   At least **one approving review** from a maintainer is required before a PR can be merged.
*   PRs should be targeted at the `dev` branch. Periodic merges from `dev` to `main` are handled by the maintainers.

## Questions?

If you have questions or need help, feel free to open an Issue on the GitHub repository.

Happy coding!
