local state = {
    active_tab = "active", -- "active", "friends", or "cluster"
    buf = nil,
    win = nil,
}

local function open_japonette_window()
    local width = math.floor(vim.o.columns * 0.85)
    local height = math.floor(vim.o.lines * 0.8)
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
        title = ' Japonette (42 Campus Active & Watchlist) ',
        title_pos = 'center',
    })
    return buf, win
end

local function run_async_cmd(cmd_args, callback)
    local cmd = "japonette"
    if vim.fn.executable("japonette") == 0 then
        if vim.fn.executable("npx") == 1 then
            cmd = "npx japonette"
        else
            callback({ "Error: 'japonette' or 'npx' is not found in PATH." })
            return
        end
    end

    local stdout = {}
    local args = {}
    for arg in cmd_args:gmatch("%S+") do
        table.insert(args, arg)
    end
    
    local executable = cmd
    if cmd == "npx" or cmd == "npx japonette" then
        executable = "npx"
        args = { "japonette", unpack(args) }
    end
    
    vim.system({ executable, unpack(args) }, {
        text = true,
        stdout = function(err, data)
            if data then
                for line in data:gmatch("[^\r\n]+") do
                    table.insert(stdout, (line:gsub("\27%[[0-9;]*[mK]", "")))
                end
            end
        end,
    }, function(obj)
        vim.schedule(function()
            if obj.code ~= 0 then
                local err_msg = "Error running command."
                if #stdout > 0 then
                    err_msg = table.concat(stdout, "\n")
                end
                callback({ "Command failed with exit code " .. obj.code, err_msg })
            else
                callback(stdout)
            end
        end)
    end)
end

local function get_login_under_cursor()
    local line = vim.api.nvim_get_current_line()
    local parts = vim.split(line, "│")
    if #parts >= 2 then
        local login = vim.trim(parts[2])
        if login ~= "login" and login ~= "" and not login:match("^─+$") then
            return login
        end
    end
    return nil
end

local function inspect_user(login)
    vim.api.nvim_echo({{"Fetching profile card for " .. login .. "...", "Normal"}}, false, {})
    run_async_cmd("user " .. login, function(output)
        if #output == 0 then
            return
        end
        
        local width = math.min(60, vim.o.columns - 10)
        local height = math.min(#output + 4, vim.o.lines - 6)
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)
        
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
        
        vim.bo[buf].modifiable = false
        vim.bo[buf].filetype = "japonette_user"
        
        local win = vim.api.nvim_open_win(buf, true, {
            relative = 'editor',
            width = width,
            height = height,
            row = row,
            col = col,
            border = 'rounded',
            title = ' Profile: ' .. login .. ' ',
            title_pos = 'center',
        })
        
        vim.keymap.set("n", "q", function() pcall(vim.api.nvim_win_close, win, true) end, { buffer = buf, silent = true })
        vim.keymap.set("n", "<Esc>", function() pcall(vim.api.nvim_win_close, win, true) end, { buffer = buf, silent = true })
    end)
end

local function render()
    if not vim.api.nvim_buf_is_valid(state.buf) then
        return
    end
    
    vim.bo[state.buf].modifiable = true
    
    local tab_active = " [1] Active Campus "
    local tab_friends = " [2] Friends List "
    local tab_cluster = " [3] Cluster Map "
    if state.active_tab == "active" then
        tab_active = "●[1] Active Campus "
        tab_friends = "  [2] Friends List "
        tab_cluster = "  [3] Cluster Map "
    elseif state.active_tab == "friends" then
        tab_active = "  [1] Active Campus "
        tab_friends = "●[2] Friends List "
        tab_cluster = "  [3] Cluster Map "
    else
        tab_active = "  [1] Active Campus "
        tab_friends = "  [2] Friends List "
        tab_cluster = "●[3] Cluster Map "
    end
    
    local header = {
        " Japonette (42 Campus Active & Watchlist) - Tab to toggle | h for help",
        " " .. tab_active .. " │ " .. tab_friends .. " │ " .. tab_cluster,
        "────────────────────────────────────────────────────────────────────────────────",
        " Loading data from 42 Intra API... Please wait.",
        "────────────────────────────────────────────────────────────────────────────────",
    }
    
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, header)
    vim.bo[state.buf].modifiable = false
    
    local cmd_args = "active"
    if state.active_tab == "friends" then
        cmd_args = "friends online"
    elseif state.active_tab == "cluster" then
        if state.cluster_name then
            cmd_args = "cluster --name " .. state.cluster_name
            state.cluster_name = nil -- Reset after one use or keep it?
            -- Actually, let's keep it until tab is switched or reloaded?
            -- For now, let's just use it once to show that cluster.
        else
            cmd_args = "cluster"
        end
    end
    
    run_async_cmd(cmd_args, function(output)
        if not vim.api.nvim_buf_is_valid(state.buf) then
            return
        end
        
        vim.bo[state.buf].modifiable = true
        
        local lines = {
            " Japonette (42 Campus Active & Watchlist) - Tab to toggle | h for help",
            " " .. tab_active .. " │ " .. tab_friends .. " │ " .. tab_cluster,
            "────────────────────────────────────────────────────────────────────────────────",
        }
        
        for _, line in ipairs(output) do
            table.insert(lines, " " .. line)
        end
        
        table.insert(lines, "────────────────────────────────────────────────────────────────────────────────")
        if state.active_tab == "cluster" then
            table.insert(lines, " [r] Reload | [C] Select Cluster | [q] Close")
        else
            table.insert(lines, " [r] Reload | [a] Add Friend | [d] Remove Friend | [Enter] Info | [c] Campus | [q] Close")
        end
        
        vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
        vim.bo[state.buf].modifiable = false
        
        local ns = vim.api.nvim_create_namespace("japonette_tui")
        vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
        
        vim.api.nvim_buf_add_highlight(state.buf, ns, "Title", 0, 0, -1)
        if state.active_tab == "active" then
            vim.api.nvim_buf_add_highlight(state.buf, ns, "DiagnosticOk", 1, 1, 20)
            vim.api.nvim_buf_add_highlight(state.buf, ns, "Comment", 1, 24, -1)
        elseif state.active_tab == "friends" then
            vim.api.nvim_buf_add_highlight(state.buf, ns, "Comment", 1, 1, 20)
            vim.api.nvim_buf_add_highlight(state.buf, ns, "DiagnosticOk", 1, 24, 46)
            vim.api.nvim_buf_add_highlight(state.buf, ns, "Comment", 1, 50, -1)
        else
            vim.api.nvim_buf_add_highlight(state.buf, ns, "Comment", 1, 1, 46)
            vim.api.nvim_buf_add_highlight(state.buf, ns, "DiagnosticOk", 1, 50, -1)
        end
        
        for i = 3, #lines - 1 do
            local current_line = lines[i]
            if current_line:match("┌") or current_line:match("├") or current_line:match("└") or current_line:match("─") then
                vim.api.nvim_buf_add_highlight(state.buf, ns, "Comment", i, 0, -1)
            elseif current_line:match("│") then
                if current_line:match("login") then
                    vim.api.nvim_buf_add_highlight(state.buf, ns, "Title", i, 0, -1)
                else
                    local start_idx = current_line:find("│")
                    if start_idx then
                        vim.api.nvim_buf_add_highlight(state.buf, ns, "Identifier", i, start_idx + 2, start_idx + 12)
                    end
                end
            elseif current_line:match("✓") then
                vim.api.nvim_buf_add_highlight(state.buf, ns, "DiagnosticOk", i, 0, -1)
            elseif current_line:match("Error") or current_line:match("failed") then
                vim.api.nvim_buf_add_highlight(state.buf, ns, "ErrorMsg", i, 0, -1)
            end
        end
        
        vim.api.nvim_buf_add_highlight(state.buf, ns, "Comment", #lines - 1, 0, -1)
    end)
end

local function set_keymaps(buf)
    local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = buf, silent = true, desc = desc })
    end
    
    map("q", function()
        pcall(vim.api.nvim_win_close, state.win, true)
    end, "Close Japonette")
    
    map("<Esc>", function()
        pcall(vim.api.nvim_win_close, state.win, true)
    end, "Close Japonette")
    
    map("<Tab>", function()
        if state.active_tab == "active" then
            state.active_tab = "friends"
        elseif state.active_tab == "friends" then
            state.active_tab = "cluster"
        else
            state.active_tab = "active"
        end
        render()
    end, "Toggle Tab")
    
    map("1", function()
        state.active_tab = "active"
        render()
    end, "Active Tab")
    
    map("2", function()
        state.active_tab = "friends"
        render()
    end, "Friends Tab")

    map("3", function()
        state.active_tab = "cluster"
        render()
    end, "Cluster Tab")
    
    map("r", function()
        render()
    end, "Reload list")
    
    map("a", function()
        vim.ui.input({ prompt = "Add Friend (42 login): " }, function(input)
            if input and input ~= "" then
                vim.api.nvim_echo({{"Adding friend " .. input .. "...", "Normal"}}, false, {})
                run_async_cmd("friends add " .. input, function(output)
                    vim.api.nvim_echo({{table.concat(output, " "), "String"}}, false, {})
                    render()
                end)
            end
        end)
    end, "Add Friend")
    
    map("d", function()
        local login = get_login_under_cursor()
        if login then
            vim.ui.input({ prompt = "Remove friend " .. login .. "? (y/N): " }, function(input)
                if input and (input:lower() == "y" or input:lower() == "yes") then
                    run_async_cmd("friends remove " .. login, function(output)
                        vim.api.nvim_echo({{table.concat(output, " "), "WarningMsg"}}, false, {})
                        render()
                    end)
                end
            end)
        end
    end, "Remove Friend")
    
    map("<CR>", function()
        local login = get_login_under_cursor()
        if login then
            inspect_user(login)
        end
    end, "Inspect User")
    
    map("o", function()
        local login = get_login_under_cursor()
        if login then
            inspect_user(login)
        end
    end, "Inspect User")
    
    map("c", function()
        vim.ui.input({ prompt = "Set Default Campus (slug): " }, function(input)
            if input and input ~= "" then
                run_async_cmd("campus set " .. input, function(output)
                    vim.api.nvim_echo({{table.concat(output, " "), "String"}}, false, {})
                    render()
                end)
            end
        end)
    end, "Set Campus")

    map("C", function()
        vim.ui.input({ prompt = "Select Cluster (name): " }, function(input)
            if input and input ~= "" then
                state.active_tab = "cluster"
                -- This is a bit of a hack to pass the name to the command
                -- We'll modify render to check for a temporary cluster_name
                state.cluster_name = input
                render()
            end
        end)
    end, "Select Cluster")
    
    map("h", function()
        local help_text = {
            " Japonette TUI Help ",
            " ================== ",
            " <Tab> : Toggle between Active, Friends, and Cluster tabs",
            " 1     : Switch to Active Campus tab",
            " 2     : Switch to Friends List tab",
            " 3     : Switch to Cluster Map tab",
            " r     : Reload the current list from the 42 Intra API",
            " a     : Add a 42 login to your local friends watchlist",
            " d     : Remove the friend under the cursor from watchlist",
            " o/Ent : Inspect details of the user under the cursor",
            " c     : Change your default campus",
            " C     : Show a specific cluster map by name",
            " q/Esc : Close this TUI window",
        }
        local width = 60
        local height = #help_text + 2
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)
        
        local h_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(h_buf, 0, -1, false, help_text)
        vim.bo[h_buf].modifiable = false
        
        local h_win = vim.api.nvim_open_win(h_buf, true, {
            relative = 'editor',
            width = width,
            height = height,
            row = row,
            col = col,
            border = 'rounded',
            title = ' Help ',
            title_pos = 'center',
        })
        
        vim.keymap.set("n", "q", function() pcall(vim.api.nvim_win_close, h_win, true) end, { buffer = h_buf, silent = true })
        vim.keymap.set("n", "<Esc>", function() pcall(vim.api.nvim_win_close, h_win, true) end, { buffer = h_buf, silent = true })
    end, "Show Help")
end

local open_japonette_tui -- forward declaration

local function open_login_terminal()
    local width = 80
    local height = 15
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
        title = ' Japonette Login ',
        title_pos = 'center',
    })
    
    local cmd = "japonette login"
    if vim.fn.executable("japonette") == 0 and vim.fn.executable("npx") == 1 then
        cmd = "npx japonette login"
    end
    
    vim.fn.termopen(cmd, {
        on_exit = function(_, exit_code)
            vim.schedule(function()
                if exit_code == 0 then
                    pcall(vim.api.nvim_win_close, win, true)
                    vim.notify("Japonette login successful!", vim.log.levels.INFO)
                    open_japonette_tui()
                else
                    vim.notify("Japonette login failed with exit code " .. exit_code, vim.log.levels.ERROR)
                end
            end)
        end
    })
    
    vim.cmd("startinsert")
end

open_japonette_tui = function()
    -- Check if user is logged in
    run_async_cmd("whoami", function(output)
        local is_logged_in = true
        for _, line in ipairs(output) do
            if line:match("Error") or line:match("Command failed") or line:match("No cached token") or line:match("not found") then
                is_logged_in = false
                break
            end
        end
        
        if #output == 0 or not is_logged_in then
            vim.ui.input({ prompt = "Japonette is not logged in. Log in now? (y/N): " }, function(input)
                if input and (input:lower() == "y" or input:lower() == "yes") then
                    open_login_terminal()
                end
            end)
            return
        end

        local buf, win = open_japonette_window()
        state.buf = buf
        state.win = win
        
        vim.bo[buf].buftype = "nofile"
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].filetype = "japonette"
        vim.bo[buf].swapfile = false
        
        set_keymaps(buf)
        render()
    end)
end

vim.api.nvim_create_user_command("Japonette", open_japonette_tui, {})

vim.api.nvim_create_user_command("JaponetteActive", function()
    state.active_tab = "active"
    open_japonette_tui()
end, {})

vim.api.nvim_create_user_command("JaponetteFriends", function()
    state.active_tab = "friends"
    open_japonette_tui()
end, {})

vim.api.nvim_create_user_command("JaponetteCluster", function()
    state.active_tab = "cluster"
    open_japonette_tui()
end, {})

vim.keymap.set("n", "<leader>Ja", "<cmd>JaponetteActive<cr>",  { desc = "Open Japonette Active TUI" })
vim.keymap.set("n", "<leader>Jf", "<cmd>JaponetteFriends<cr>", { desc = "Open Japonette Friends TUI" })
vim.keymap.set("n", "<leader>Jm", "<cmd>JaponetteCluster<cr>", { desc = "Open Japonette Cluster Map" })
