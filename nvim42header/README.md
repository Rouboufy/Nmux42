# 42Header Plugin for Neovim

A lightweight, configurable plugin for managing 42 school file headers in Neovim.

## Features

- 🎯 **Easy Header Management**: Insert and update 42 school headers with simple commands
- 🎨 **Multiple Formats**: Choose between full and minimal header styles
- ⚡ **Smart Updates**: Automatically detect existing headers and update timestamp
- 🔧 **Highly Configurable**: Customize username, email, and format
- 🎹 **Intuitive Keymaps**: Default keybindings for common operations
- 📝 **42 Compliant**: Follows official 42 school header format

## Installation

### Using lazy.nvim
```lua
{
    "your-username/nvim42header",
    config = function()
        require("nvim42header").setup({
            user = "your_username",
            mail = "your_email@student.42.fr",
            header_format = "full" -- or "minimal"
        })
    end
}
```

### Using packer.nvim
```lua
use {
    "your-username/nvim42header",
    config = function()
        require("nvim42header").setup({
            user = "your_username",
            mail = "your_email@student.42.fr"
        })
    end
}
```

## Configuration

### Default Configuration
```lua
{
    user = "your_username",
    mail = "your_email@student.42.fr",
    auto_update = false,
    header_format = "full" -- "full" or "minimal"
}
```

### Options

- `user` (string): Your 42 username
- `mail` (string): Your 42 email address
- `auto_update` (boolean): Automatically update headers on save (not implemented yet)
- `header_format` (string): Header style - "full" or "minimal"

## Commands

| Command | Description |
|---------|-------------|
| `:Stdheader` | Insert new header or update existing one |
| `:StdheaderInsert` | Insert a new header (even if one exists) |
| `:StdheaderUpdate` | Update existing header timestamp |
| `:42SetUser [username]` | Set or show current username |
| `:42SetMail [email]` | Set or show current email |
| `:42Format [type]` | Set or show header format (full/minimal) |

## Keymaps

| Keymap | Action |
|--------|--------|
| `<F1>` | Insert/update 42 header |
| `<leader>h` | Insert/update 42 header |
| `<leader>hi` | Insert new 42 header |
| `<leader>hu` | Update existing header |

## Header Formats

### Full Format
```c
/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_printf.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: blanglai <blanglai@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/01/14 21:30:00 by blanglai          #+#    #+#             */
/*   Updated: 2025/01/14 21:30:00 by blanglai         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */
```

### Minimal Format
```c
/* ************************************************************************** */
/*   ft_printf.c                               :+:      :+:    :+:   */
/*   By: blanglai <blanglai@student.42.fr> +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/01/14 21:30:00 by blanglai #+#    #+#             */
/*   Updated: 2025/01/14 21:30:00 by blanglai ###   ########.fr       */
/* ************************************************************************** */
```

## Usage Examples

### Basic Setup
```lua
require("nvim42header").setup({
    user = "blanglai",
    mail = "blanglai@student.42.fr"
})
```

### Custom Configuration
```lua
require("nvim42header").setup({
    user = "your_username",
    mail = "your_email@student.42.fr",
    header_format = "minimal"
})
```

### Runtime Configuration
```vim
" Set username
:42SetUser blanglai

" Set email  
:42SetMail blanglai@student.42.fr

" Use minimal format
:42Format minimal

" Insert header
:Stdheader

" Update existing header
:StdheaderUpdate
```

## Integration with 42 Workflow

This plugin is designed to work seamlessly with the 42 school workflow:

1. **Automatic Detection**: Automatically detects existing headers
2. **Smart Updates**: Only updates the timestamp when a header exists
3. **Format Compliance**: Follows official 42 header format standards
4. **Quick Access**: Simple commands and keymaps for fast insertion

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve this plugin!

## License

MIT License - feel free to use and modify for your needs.