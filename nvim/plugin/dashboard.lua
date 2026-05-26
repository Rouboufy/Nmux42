local ok, alpha = pcall(require, "alpha")
if not ok then
    return
end

local dashboard = require("alpha.themes.dashboard")

local logo = {
    [[  _   _                            _  _    ____   ]],
    [[ | \ | | _ __ ___   _   _ __  __  | || |  |___ \  ]],
    [[ |  \| || '_ ` _ \ | | | |\ \/ /  | || |_   __) | ]],
    [[ | |\  || | | | | || |_| | >  <   |__   _| / __/  ]],
    [[ |_| \_||_| |_| |_| \__,_|/_/\_\     |_|  |_____| ]],
}
local colors = {
    "DiagnosticError",
    "DiagnosticWarning",
    "DiagnosticInfo",
    "DiagnosticHint",
    "Type",
}

local header_elements = {}
for i, line in ipairs(logo) do
    table.insert(header_elements, {
        type = "text",
        val = line,
        opts = {
            position = "center",
            hl = colors[i],
        }
    })
end

dashboard.section.buttons.val = {
    dashboard.button("n", "  New File",             "<cmd>enew<cr>"),
    dashboard.button("f", "  Find File",            "<cmd>Telescope find_files<cr>"),
    dashboard.button("r", "  Recent Files",         "<cmd>Telescope oldfiles<cr>"),
    dashboard.button("e", "  File Explorer",        "<cmd>Neotree toggle<cr>"),
    dashboard.button("g", "  Git (TUI)",            "<cmd>GitUI<cr>"),
    dashboard.button("J", "  Japonette Active",     "<cmd>JaponetteActive<cr>"),
    dashboard.button("O", "👥  Japonette Friends",   "<cmd>JaponetteFriends<cr>"),
    dashboard.button("v", "  Vim Bindings",         "<cmd>VimBindings<cr>"),
    dashboard.button("p", "󰏖  Plugins Manager",     "<cmd>HelpPlugins<cr>"),
    dashboard.button("c", "  Edit Config",          "<cmd>e ~/.config/nvim/init.lua<cr>"),
    dashboard.button("q", "  Quit",                 "<cmd>qa<cr>"),
}

dashboard.section.footer.val = "Welcome to Nmux42 development environment!"
dashboard.section.footer.opts.hl = "Comment"

-- Override layout to use line-by-line colorful logo elements
dashboard.config.layout = {
    { type = "padding", val = 2 },
    header_elements[1],
    header_elements[2],
    header_elements[3],
    header_elements[4],
    header_elements[5],
    { type = "padding", val = 2 },
    dashboard.section.buttons,
    { type = "padding", val = 1 },
    dashboard.section.footer,
}

alpha.setup(dashboard.config)
