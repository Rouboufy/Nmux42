local themes = {
    "tokyonight",
    "tokyonight-storm",
    "tokyonight-night",
    "tokyonight-day",
    "catppuccin",
    "catppuccin-latte",
    "catppuccin-frappe",
    "catppuccin-macchiato",
    "catppuccin-mocha",
    "gruvbox",
    "nord",
    "cyberdream",
    "rose-pine",
    "rose-pine-moon",
    "rose-pine-dawn",
    "vscode",
    "aether",
    "matteblack",
    "kanagawa",
    "kanagawa-dragon",
    "kanagawa-wave",
    "nightfox",
    "nordfox",
}

local function open_theme_selector()
    local original_colorscheme = vim.g.colors_name or "default"
    
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.7)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    local left_width = math.floor(width * 0.3)
    local right_width = width - left_width - 2
    
    local left_buf = vim.api.nvim_create_buf(false, true)
    local left_win = vim.api.nvim_open_win(left_buf, true, {
        relative = 'editor',
        width = left_width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
        title = ' Themes ',
        title_pos = 'center',
    })
    
    local right_buf = vim.api.nvim_create_buf(false, true)
    local right_win = vim.api.nvim_open_win(right_buf, false, {
        relative = 'editor',
        width = right_width,
        height = height,
        row = row,
        col = col + left_width + 2,
        style = 'minimal',
        border = 'rounded',
        title = ' Live Preview ',
        title_pos = 'center',
    })
    
    local preview_text = {
        " -- Theme Preview Code Sample",
        " local M = {}",
        "",
        " ---@class User",
        " -- Representing a 42 Intra User profile",
        " local User = {",
        "     login = \"blanglai\",",
        "     level = 42.42,",
        "     is_active = true,",
        " }",
        "",
        " function M.inspect_user(user)",
        "     if user.is_active then",
        "         print(\"User \" .. user.login .. \" is active at campus!\")",
        "     else",
        "         print(\"User \" .. user.login .. \" is offline.\")",
        "     end",
        "     return User",
        " end",
        "",
        " -- Setup function",
        " function M.setup(opts)",
        "     opts = opts or {}",
        "     print(\"Setting up Nmux42 theme... \", opts)",
        " end",
        "",
        " return M",
    }
    vim.api.nvim_buf_set_lines(right_buf, 0, -1, false, preview_text)
    vim.bo[right_buf].filetype = "lua"
    
    local theme_lines = {}
    for _, t in ipairs(themes) do
        table.insert(theme_lines, "  " .. t)
    end
    vim.api.nvim_buf_set_lines(left_buf, 0, -1, false, theme_lines)
    
    local ns = vim.api.nvim_create_namespace("theme_selector")
    
    local function highlight_current_line()
        if not vim.api.nvim_win_is_valid(left_win) then return end
        local r = vim.api.nvim_win_get_cursor(left_win)[1]
        vim.api.nvim_buf_clear_namespace(left_buf, ns, 0, -1)
        vim.api.nvim_buf_add_highlight(left_buf, ns, "Visual", r - 1, 0, -1)
        
        local selected = themes[r]
        if selected then
            pcall(vim.cmd.colorscheme, selected)
        end
    end
    
    vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = left_buf,
        callback = highlight_current_line,
    })
    
    highlight_current_line()
    
    local function close()
        pcall(vim.api.nvim_win_close, left_win, true)
        pcall(vim.api.nvim_win_close, right_win, true)
    end
    
    local map = function(key, fn)
        vim.keymap.set("n", key, fn, { buffer = left_buf, silent = true })
    end
    
    map("<Esc>", function()
        pcall(vim.cmd.colorscheme, original_colorscheme)
        close()
    end)
    map("q", function()
        pcall(vim.cmd.colorscheme, original_colorscheme)
        close()
    end)
    
    map("<CR>", function()
        local r = vim.api.nvim_win_get_cursor(left_win)[1]
        local selected = themes[r]
        if selected then
            local config_dir = vim.fn.stdpath("config")
            local file = io.open(config_dir .. "/lua/plugins/theme.lua", "w")
            if file then
                file:write("return \"" .. selected .. "\"\n")
                file:close()
                vim.api.nvim_echo({{"Colorscheme saved: " .. selected, "String"}}, false, {})
            else
                vim.api.nvim_echo({{"Failed to save colorscheme config.", "ErrorMsg"}}, false, {})
            end
            -- Sync tmux theme in the background (non-blocking)
            local theme_script = vim.fn.stdpath("config") .. "/../tmux-theme.sh"
            if vim.fn.filereadable(theme_script) == 0 then
                -- Fallback: try standard install location
                theme_script = vim.fn.expand("~/.config/tmux/tmux-theme.sh")
            end
            if vim.fn.filereadable(theme_script) == 1 then
                vim.system({ "bash", theme_script, selected }, { detach = true })
            end
        end
        close()
    end)
end

vim.api.nvim_create_user_command("ThemeSelect", open_theme_selector, {})
vim.keymap.set("n", "<leader>th", "<cmd>ThemeSelect<cr>", { desc = "Select Colorscheme" })
