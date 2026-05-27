local M = {}

function M.setup(opts)
    opts = opts or {}
    local group = vim.api.nvim_create_augroup("NormFormat", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        pattern = { "*.c", "*.h" },
        callback = function()
            M.format()
        end,
    })
end

function M.format()
    local bufnr = vim.api.nvim_get_current_buf()
    local all_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    if #all_lines == 0 then return end

    -- Detect 42 Header
    local has_header = false
    if #all_lines >= 12 and all_lines[1]:match("^/%* %*%*%*%*") then
        has_header = true
    end

    local header_lines = {}
    if has_header then
        for i = 1, 12 do
            table.insert(header_lines, all_lines[i])
        end
    end

    -- Step 1: Alignment pass
    if vim.fn.executable("clang-format") == 1 then
        local view = vim.fn.winsaveview()
        local cmd = "silent! %!clang-format --style='{BasedOnStyle: LLVM, UseTab: Always, TabWidth: 4, IndentWidth: 4, BreakBeforeBraces: Allman, AllowShortIfStatementsOnASingleLine: false, ColumnLimit: 80, AlwaysBreakAfterReturnType: None}'"
        vim.cmd(cmd)
        vim.fn.winrestview(view)
    end

    -- Step 2: Line-by-Line Logic
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local result = {}
    local in_function = false
    
    for i, line in ipairs(lines) do
        local line_idx = i - 1
        
        if has_header and line_idx < 12 then
            table.insert(result, header_lines[i] or line)
        else
            line = line:gsub("%s+$", "") -- Trim trailing
            
            -- Indentation: Force Tabs
            while line:match("^%t*    ") do
                line = line:gsub("^(%t*)    ", "%1\t")
            end
            
            -- Semantic Fixes
            if line:match("%s[%a_][%a%d_]*%(%)") or line:match("^[%a_][%a%d_]*%(%)") then
                 line = line:gsub("%(%)", "(void)")
            end
            if line:match("^%s*return%s+[^%(].*;$") then
                local indent, val = line:match("^(%s*)return%s+(.-);$")
                if val and val ~= "" and not val:match("^%b()$") then
                    line = indent .. "return (" .. val .. ");"
                end
            end

            -- Type-Name Tabbing (Improved to handle multi-word types, pointers and assignments)
            if not line:match("^#") and not line:match("^{") and not line:match("^}") then
                -- Match indentation, type (greedy, excluding ( and ,), and name+rest
                local indent, type, name_rest = line:match("^([%t%s]*)([^%(%,]+%S)%s+([%a_%*][%a%d_]*.*%;)")
                
                if indent and type and name_rest then
                    local is_keyword = type:match("^return$") or type:match("^if$") or type:match("^while$") or type:match("^for$") or type:match("^switch$") or type:match("^else$")
                    if not is_keyword then
                        line = indent .. type .. "\t" .. name_rest
                    end
                elseif line:match("^[%a_][%a%d_%*]+%s+[%a_][%a%d_]*%s*%(") then
                    -- Functions at top level
                    local type_func, name_rest_func = line:match("^([%a_][%a%d_%*]*.-)%s+([%a_][%a%d_]*.*)")
                    if type_func and name_rest_func then
                        line = type_func .. "\t" .. name_rest_func
                    end
                end
            end
            
            -- Empty Line Logic
            if line:match("^{") then in_function = true end
            if line:match("^}") then in_function = false end
            
            local is_empty = line:match("^%s*$")
            local skip = false
            if in_function and is_empty then
                local prev = i > 1 and result[#result] or ""
                local next = i < #lines and lines[i+1] or ""
                if prev:match("^{") or next:match("^}") then skip = true end
            end
            if is_empty and #result > 0 and result[#result] == "" then skip = true end

            if not skip then
                table.insert(result, line)
            end
        end
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result)
end

return M
