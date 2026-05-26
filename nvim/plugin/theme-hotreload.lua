local theme_file = vim.fn.stdpath("config") .. "/lua/plugins/theme.lua"

local function apply_theme()
    package.loaded["plugins.theme"] = nil
    local theme_ok, theme_specs = pcall(require, "plugins.theme")
    if not theme_ok or type(theme_specs) ~= "table" then return end

    local theme_spec = nil
    local colorscheme_name = nil
    for _, spec in ipairs(theme_specs) do
        if spec[1] and spec[1] ~= "LazyVim/LazyVim" then
            theme_spec = spec
        elseif spec[1] == "LazyVim/LazyVim" and spec.opts and spec.opts.colorscheme then
            colorscheme_name = spec.opts.colorscheme
        end
    end

    if theme_spec then
        -- Ensure the plugin is present in runtimepath
        require("manage").ensure_plugin(theme_spec)

        -- Apply theme settings
        vim.cmd("highlight clear")
        if vim.fn.exists("syntax_on") then
            vim.cmd("syntax reset")
        end
        vim.o.background = "dark"

        if type(theme_spec.config) == "function" then
            pcall(theme_spec.config)
        elseif colorscheme_name then
            pcall(vim.cmd.colorscheme, colorscheme_name)
        end

        -- Apply transparency settings if they exist
        local transparency_file = vim.fn.stdpath("config") .. "/after/plugin/transparency.lua"
        if vim.fn.filereadable(transparency_file) == 1 then
            pcall(vim.cmd.source, transparency_file)
        end

        vim.cmd("redraw!")
    end
end

-- Apply on startup
vim.schedule(apply_theme)

-- Watch for changes to the theme.lua symlink target
local w = vim.uv.new_fs_event()
if w then
    w:start(theme_file, {}, function(err, filename, events)
        if err then return end
        vim.schedule(apply_theme)
    end)
end
