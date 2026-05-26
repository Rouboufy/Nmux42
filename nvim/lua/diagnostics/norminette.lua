local M = {}

local ns = vim.api.nvim_create_namespace("norminette")

function M.run()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype ~= "c" then return end
    
    local path = vim.api.nvim_buf_get_name(buf)
    if path == "" then return end

    vim.fn.jobstart({ "norminette", path }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if not data then return end
            local diagnostics = {}
            for _, line in ipairs(data) do
                -- Pattern: Error: NAME (line: X, col: Y): Description
                local type, l, c, desc = line:match("Error:%s+(%S+)%s+%(line:%s+(%d+),%col:%s+(%d+)%):%s+(.*)")
                if type then
                    table.insert(diagnostics, {
                        lnum = tonumber(l) - 1,
                        col = tonumber(c) - 1,
                        severity = vim.diagnostic.severity.ERROR,
                        source = "norminette",
                        message = type .. ": " .. desc,
                    })
                end
            end
            vim.diagnostic.set(ns, buf, diagnostics)
        end,
    })
end

function M.setup()
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
        pattern = "*.c,*.h",
        callback = function()
            M.run()
        end,
    })
end

return M
