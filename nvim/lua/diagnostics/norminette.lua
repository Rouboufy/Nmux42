local M = {}

local ns = vim.api.nvim_create_namespace("norminette")

local function strip_ansi(str)
    return str:gsub("\27%[[0-9;]*[mK]", "")
end

function M.run()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype ~= "c" and vim.bo[buf].filetype ~= "h" then return end
    
    local path = vim.api.nvim_buf_get_name(buf)
    if path == "" or vim.fn.filereadable(path) == 0 then return end

    -- Search for norminette in common paths if not in PATH
    local cmd = "norminette"
    if vim.fn.executable(cmd) == 0 then
        local local_bin = vim.fn.expand("~/.local/bin/norminette")
        if vim.fn.executable(local_bin) == 1 then
            cmd = local_bin
        else
            -- Don't spam error notifications, just return silently
            return
        end
    end

    vim.fn.jobstart({ cmd, path }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if not data then return end
            local diagnostics = {}
            for _, line in ipairs(data) do
                local clean_line = strip_ansi(line)
                -- Pattern: Error: NAME (line: X, col: Y): Description
                local err_name, l, c, desc = clean_line:match("Error:%s+(%S+)%s+%(line:%s+(%d+),%s+col:%s+(%d+)%):%s+(.*)")
                
                if err_name and l and c then
                    table.insert(diagnostics, {
                        lnum = tonumber(l) - 1,
                        col = math.max(0, tonumber(c) - 1),
                        severity = vim.diagnostic.severity.ERROR,
                        source = "norminette",
                        message = err_name .. ": " .. desc,
                    })
                end
            end
            vim.diagnostic.set(ns, buf, diagnostics)
        end,
        on_stderr = function(_, data)
            if data and #data > 0 and data[1] ~= "" then
                -- Optional: handle norminette errors
            end
        end
    })
end

function M.setup()
    local group = vim.api.nvim_create_augroup("NorminetteLSP", { clear = true })
    
    -- Run on enter and save
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
        group = group,
        pattern = { "*.c", "*.h" },
        callback = function()
            M.run()
        end,
    })
    
    -- Debounced run on insert leave to show errors as you type
    local timer = nil
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = group,
        pattern = { "*.c", "*.h" },
        callback = function()
            if timer then timer:stop() end
            timer = vim.defer_fn(function()
                M.run()
            end, 500)
        end,
    })
end

return M
