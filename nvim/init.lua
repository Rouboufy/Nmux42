require("config.options")
require("config.keybinds")
require("manage").setup()

-- Custom 42 Diagnostics
vim.notify("Nmux42: Initializing custom diagnostics...", vim.log.levels.INFO)
pcall(function() require("diagnostics.norminette").setup() end)

-- Load active colorscheme dynamically
local active_theme = "tokyonight"
local theme_ok, t = pcall(require, "plugins.theme")
if theme_ok and type(t) == "string" then
    active_theme = t
end
pcall(vim.cmd.colorscheme, active_theme)

