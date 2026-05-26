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
        local mise_bin = vim.fn.expand("~/.local/share/mise/installs/python/3.14.5/bin/norminette")
        if vim.fn.executable(mise_bin) == 1 then
            cmd = mise_bin
        else
            return
        end
    end

    print("NORMINETTE_DEBUG: Running on " .. vim.fn.fnamemodify(path, ":t"))

    vim.fn.jobstart({ cmd, path }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if not data then return end
            local diagnostics = {}
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
                end
            end
            vim.diagnostic.set(ns, buf, diagnostics)
            print("NORMINETTE_DEBUG: Found " .. #diagnostics .. " errors")
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
