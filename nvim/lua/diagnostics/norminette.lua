local M = {}

local ns = vim.api.nvim_create_namespace("norminette")

local function strip_ansi(str)
    return str:gsub("\27%[[0-9;]*[mK]", "")
end

function M.run()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype ~= "c" then return end
    
    local path = vim.api.nvim_buf_get_name(buf)
    if path == "" or vim.fn.filereadable(path) == 0 then return end

    vim.fn.jobstart({ "norminette", path }, {
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
    })
end

function M.setup()
    local group = vim.api.nvim_create_augroup("NorminetteLSP", { clear = true })
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
        group = group,
        pattern = { "*.c", "*.h" },
        callback = function()
            M.run()
        end,
    })
end

return M
