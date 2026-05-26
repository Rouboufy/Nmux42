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

    local cmd = "norminette"
    if vim.fn.executable(cmd) == 0 then
        -- Try mise path specifically since 'which' found it there
        local mise_bin = vim.fn.expand("~/.local/share/mise/installs/python/3.14.5/bin/norminette")
        if vim.fn.executable(mise_bin) == 1 then
            cmd = mise_bin
        else
            vim.notify("Norminette: binary NOT FOUND in PATH", vim.log.levels.ERROR)
            return
        end
    end

    vim.notify("Norminette: Checking " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)

    vim.fn.jobstart({ cmd, path }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if not data then return end
            local diagnostics = {}
            local error_count = 0
            for _, line in ipairs(data) do
                local clean_line = strip_ansi(line)
                local err_name, l, c, desc = clean_line:match("Error:%s+(%S+)%s+%(line:%s+(%d+),%s+col:%s+(%d+)%):%s+(.*)")
                
                if err_name and l and c then
                    table.insert(diagnostics, {
                        lnum = tonumber(l) - 1,
                        col = math.max(0, tonumber(c) - 1),
                        severity = vim.diagnostic.severity.ERROR,
                        source = "norminette",
                        message = err_name .. ": " .. desc,
                    })
                    error_count = error_count + 1
                end
            end
            vim.diagnostic.set(ns, buf, diagnostics)
            if error_count > 0 then
                vim.notify("Norminette: Found " .. error_count .. " errors", vim.log.levels.WARN)
            else
                vim.notify("Norminette: OK!", vim.log.levels.INFO)
            end
        end,
    })
end

function M.setup()
    local group = vim.api.nvim_create_augroup("NorminetteLSP", { clear = true })
    
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
        group = group,
        pattern = { "*.c", "*.h" },
        callback = function()
            M.run()
        end,
    })
end

return M
