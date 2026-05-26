local function open_floating_help(title, lines, edit_action)
    local width = 74
    local height = math.min(#lines + 2, vim.o.lines - 8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
        title = " " .. title .. " ",
        title_pos = 'center',
    })

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    vim.api.nvim_set_option_value("filetype", "helpmenu", { buf = buf })

    -- Map keys to close or edit
    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    vim.keymap.set('n', 'q', close, { buffer = buf, silent = true })
    vim.keymap.set('n', '<esc>', close, { buffer = buf, silent = true })
    vim.keymap.set('n', 'e', function()
        close()
        edit_action()
    end, { buffer = buf, silent = true })
end

-- Keybinds Help Menu definition
local function show_keybinds_help()
    local lines = {
        "  Keybinding       Action / Description",
        "  ──────────       ────────────────────",
        "  <leader>e        Toggle Neo-tree File Explorer",
        "  <leader>th       Toggle Live Theme Selector TUI",
        "  <leader>ja       Open Japonette TUI (Active Campus)",
        "  <leader>jf       Open Japonette TUI (Friends List)",
        "  <leader>ft       Toggle Floating Terminal (Flterm)",
        "  <leader>qq       Reformat Parenthesized Content",
        "  <leader>ff       Fuzzy find files (Telescope)",
        "  <leader>fo       Fuzzy find recent files",
        "  <leader>fg       Search string across codebase (ripgrep)",
        "  <leader>fs       Search current word under cursor",
        "  <leader>fb       Fuzzy find active buffers",
        "  <leader>fh       Search Neovim help documentation",
        "  <leader>fc       Search files matching current filename",
        "  <leader>fi       Search Neovim configuration files",
        "  <leader>db       Go back to welcoming dashboard menu",
        "  C-k / C-j        Move up/down inside menus/Telescope",
        "  Esc Esc          Exit Terminal Mode in Flterm",
        "  ",
        "  [e] Edit Keybindings File   │   [q / Esc] Close Window"
    }
    open_floating_help("Nmux42 Keybindings Help", lines, function()
        vim.cmd("edit " .. vim.fn.stdpath("config") .. "/lua/config/keybinds.lua")
    end)
end

-- Plugins Help Menu definition
local function show_plugins_help()
    local lines = {
        "  Plugin Name                   Purpose / Features",
        "  ───────────                   ──────────────────",
        "  nvim-treesitter               Syntax highlighting & parsing",
        "  neo-tree.nvim                 Modern tree-style file explorer",
        "  telescope.nvim                Fuzzy finder UI & file explorer",
        "  alpha-nvim                    Premium welcoming dashboard",
        "  lualine.nvim                  Sleek custom status line",
        "  mason.nvim                    Installer for LSPs, formatters & linters",
        "  harpoon                       Mark & jump to active files quickly",
        "  undotree                      Visual undo history branching tree",
        "  vim-42header                  Official 42 school file headers",
        "  vim-oscyank                   Copy text over SSH/TMUX natively",
        "  cyberdream.nvim               Main premium dark theme",
        "  tokyonight.nvim               Sleek modern color schemes",
        "  catppuccin/gruvbox/nord       Beautiful color palettes preinstalled",
        "  ",
        "  [e] Edit Plugins List File   │   [q / Esc] Close Window"
    }
    open_floating_help("Nmux42 Plugins Manager", lines, function()
        vim.cmd("edit " .. vim.fn.stdpath("config") .. "/lua/plugin-list.lua")
    end)
end

-- Syntax coloring for the custom help menus
vim.api.nvim_create_autocmd("FileType", {
    pattern = "helpmenu",
    callback = function()
        vim.cmd("syntax match HelpMenuKeybind '^\\s\\+<[^>]*>'")
        vim.cmd("syntax match HelpMenuKeybind '^\\s\\+C-[j|k]'")
        vim.cmd("syntax match HelpMenuKeybind '^\\s\\+Esc Esc'")
        vim.cmd("syntax match HelpMenuPlugin '^\\s\\+[a-zA-Z0-9.-]\\+\\(/[^ ]*\\)\\?'")
        vim.cmd("syntax match HelpMenuHeader '^\\s\\+Keybinding.*'")
        vim.cmd("syntax match HelpMenuHeader '^\\s\\+Plugin Name.*'")
        vim.cmd("syntax match HelpMenuDivider '^\\s\\+──.*'")
        vim.cmd("syntax match HelpMenuAction '^\\s\\+\\[e\\].*'")

        vim.cmd("highlight default link HelpMenuKeybind Special")
        vim.cmd("highlight default link HelpMenuPlugin Identifier")
        vim.cmd("highlight default link HelpMenuHeader Title")
        vim.cmd("highlight default link HelpMenuDivider Comment")
        vim.cmd("highlight default link HelpMenuAction Keyword")
    end
})

-- User commands
vim.api.nvim_create_user_command("HelpKeybinds", show_keybinds_help, {})
vim.api.nvim_create_user_command("HelpPlugins", show_plugins_help, {})

-- Keymaps
vim.keymap.set("n", "<leader>hk", "<cmd>HelpKeybinds<CR>", { desc = "Show Keybindings Help Menu" })
vim.keymap.set("n", "<leader>hp", "<cmd>HelpPlugins<CR>", { desc = "Show Plugins Help Menu" })
