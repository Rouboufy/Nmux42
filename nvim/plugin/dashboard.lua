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
    dashboard.button("n", "󰝒  New File",             "<cmd>NewFile<cr>"),
    dashboard.button("f", "  Find File",            "<cmd>Telescope find_files<cr>"),
    dashboard.button("r", "󰄉  Recent Files",         "<cmd>Telescope oldfiles<cr>"),
    dashboard.button("e", "󰙅  File Explorer",        "<cmd>Neotree toggle<cr>"),
    dashboard.button("g", "󰊢  Git (TUI)",            "<cmd>GitUI<cr>"),
    dashboard.button("J", "󰴓  Japonette Active",     "<cmd>JaponetteActive<cr>"),
    dashboard.button("O", "  Japonette Friends",    "<cmd>JaponetteFriends<cr>"),
    dashboard.button("M", "󰹑  Cluster Map",          "<cmd>JaponetteCluster<cr>"),
    dashboard.button("v", "󰌌  Vim Bindings",         "<cmd>VimBindings<cr>"),
    dashboard.button("p", "󰏖  Plugins Manager",     "<cmd>HelpPlugins<cr>"),
    dashboard.button("u", "󰚰  Update Nmux42",        function()
        local repo_info_ok, repo_info = pcall(require, "config.repo_info")
        local repo_path = repo_info_ok and repo_info.path or (vim.fn.expand("~/Nmux42"))
        local update_script = repo_path .. "/update.sh"
        
        if vim.fn.executable(update_script) == 1 then
            -- Run update script in a floating terminal
            local width = 80
            local height = 20
            local row = math.floor((vim.o.lines - height) / 2)
            local col = math.floor((vim.o.columns - width) / 2)
            local buf = vim.api.nvim_create_buf(false, true)
            local win = vim.api.nvim_open_win(buf, true, {
                relative = 'editor', width = width, height = height,
                row = row, col = col, border = 'rounded',
                title = ' Nmux42 Update ', title_pos = 'center',
            })
            vim.fn.termopen(update_script, {
                on_exit = function(_, exit_code)
                    if exit_code == 0 then
                        vim.api.nvim_win_close(win, true)
                        
                        -- Prompt user for reload
                        vim.schedule(function()
                            local confirm_buf = vim.api.nvim_create_buf(false, true)
                            local c_width = 50
                            local c_height = 5
                            local c_row = math.floor((vim.o.lines - c_height) / 2)
                            local c_col = math.floor((vim.o.columns - c_width) / 2)
                            
                            local confirm_win = vim.api.nvim_open_win(confirm_buf, true, {
                                relative = 'editor', width = c_width, height = c_height,
                                row = c_row, col = c_col, border = 'rounded',
                                title = ' Nmux42 Reload ', title_pos = 'center',
                            })
                            
                            vim.api.nvim_buf_set_lines(confirm_buf, 0, -1, false, {
                                "",
                                "  Nmux42 has been updated successfully!",
                                "  A reload is required to apply the changes.",
                                "",
                                "         [y] Reload now    [n] Not now"
                            })
                            
                            local function close_confirm()
                                if vim.api.nvim_win_is_valid(confirm_win) then
                                    vim.api.nvim_win_close(confirm_win, true)
                                end
                            end
                            
                            vim.keymap.set('n', 'y', function()
                                close_confirm()
                                vim.notify("Nmux42: Performing hard reload...", vim.log.levels.INFO)
                                
                                -- 1. Clear Nmux42 related packages from cache
                                for name, _ in pairs(package.loaded) do
                                    if name:match("^config%.") or name:match("^manage$") or 
                                       name:match("^plugins%.") or name:match("^diagnostics%.") then
                                        package.loaded[name] = nil
                                    end
                                end
                                
                                -- 2. Re-execute init.lua
                                local init_path = vim.fn.stdpath("config") .. "/init.lua"
                                if vim.fn.filereadable(init_path) == 1 then
                                    dofile(init_path)
                                end
                                
                                -- 3. Force dashboard to redraw
                                vim.cmd("Alpha")
                            end, { buffer = confirm_buf, silent = true })
                            
                            vim.keymap.set('n', 'n', function()
                                close_confirm()
                                vim.notify("Update applied. Restart Neovim manually to see changes.", vim.log.levels.WARN)
                            end, { buffer = confirm_buf, silent = true })
                        end)
                    end
                end
            })
            vim.cmd("startinsert")
        else
            vim.notify("Update script not found at: " .. update_script, vim.log.levels.ERROR)
        end
    end),
    dashboard.button("c", "󰒓  Edit Config",          "<cmd>e ~/.config/nvim/init.lua<cr>"),
    dashboard.button("q", "󰈆  Quit",                 "<cmd>qa<cr>"),
}

local repo_info_ok, repo_info = pcall(require, "config.repo_info")
local version = repo_info_ok and repo_info.version or "0.0.1"
dashboard.section.footer.val = "Nmux42 v" .. version .. " — Welcome to your development environment!"
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
