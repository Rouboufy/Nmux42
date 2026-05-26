local ok, alpha = pcall(require, "alpha")
if not ok then
    return
end

local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
    [[  _   _                            _  _    ____   ]],
    [[ | \ | | _ __ ___   _   _ __  __  | || |  |___ \  ]],
    [[ |  \| || '_ ` _ \ | | | |\ \/ /  | || |_   __) | ]],
    [[ | |\  || | | | | || |_| | >  <   |__   _| / __/  ]],
    [[ |_| \_||_| |_| |_| \__,_|/_/\_\     |_|  |_____| ]],
}
dashboard.section.header.opts.hl = {
    "DiagnosticError",
    "DiagnosticWarning",
    "DiagnosticInfo",
    "DiagnosticHint",
    "Type",
}

dashboard.section.buttons.val = {
    dashboard.button("n", "  New File", "<cmd>enew<cr>"),
    dashboard.button("f", "  Find File", "<cmd>Telescope find_files<cr>"),
    dashboard.button("r", "  Recent Files", "<cmd>Telescope oldfiles<cr>"),
    dashboard.button("e", "  File Explorer", "<cmd>Neotree toggle<cr>"),
    dashboard.button("j", "  Japonette Active", "<cmd>JaponetteActive<cr>"),
    dashboard.button("o", "👥  Japonette Friends", "<cmd>JaponetteFriends<cr>"),
    dashboard.button("p", "󰏖  Plugins Manager", "<cmd>e ~/.config/nvim/lua/plugin-list.lua<cr>"),
    dashboard.button("c", "  Edit Config", "<cmd>e ~/.config/nvim/init.lua<cr>"),
    dashboard.button("h", "  Help Keybinds", "<cmd>e ~/.config/nvim/lua/config/keybinds.lua<cr>"),
    dashboard.button("q", "  Quit", "<cmd>qa<cr>"),
}

-- Add footer with a welcoming message
dashboard.section.footer.val = "Welcome to Nmux42 development environment!"
dashboard.section.footer.opts.hl = "Comment"

alpha.setup(dashboard.opts)
