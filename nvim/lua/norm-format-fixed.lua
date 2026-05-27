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

    -- Detect 42 Header: find the end of the header block
    local header_end = 0
    if #all_lines >= 1 and all_lines[1]:match("^/%* %*%*%*%*") then
        for i = 1, math.min(#all_lines, 20) do
            if i > 1 and all_lines[i]:match("^/%* %*%*%*%*") then
                header_end = i
                break
            end
        end
        -- Fallback: if we found the opening but not the closing, check for 11-line standard header
        if header_end == 0 and #all_lines >= 11 then
            header_end = 11
        end
    end

    -- Save original header lines (completely untouched)
    local header_lines = {}
    for i = 1, header_end do
        table.insert(header_lines, all_lines[i])
    end

    -- Step 1: Run clang-format ONLY on code after the header
    if vim.fn.executable("clang-format") == 1 and header_end < #all_lines then
        local view = vim.fn.winsaveview()
        -- Use a range to only format lines after the header
        local start_line = header_end + 1
        local end_line = #all_lines
        local range_cmd = string.format(
            "silent! %d,%d!clang-format --style='{BasedOnStyle: LLVM, UseTab: Always, TabWidth: 4, IndentWidth: 4, BreakBeforeBraces: Allman, AllowShortIfStatementsOnASingleLine: false, ColumnLimit: 80, AlwaysBreakAfterReturnType: None}'",
            start_line, end_line
        )
        vim.cmd(range_cmd)
        vim.fn.winrestview(view)
    end

    -- Step 2: Re-read the buffer after clang-format
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    -- Step 3: Line-by-Line Logic (skip header lines entirely)
    local result = {}
    local in_function = false
    local last_was_decl = false

    -- First, insert the original header lines untouched
    for _, hline in ipairs(header_lines) do
        table.insert(result, hline)
    end

    -- Process only lines after the header
    local code_start = header_end + 1
    for i = code_start, #lines do
        local line = lines[i]
        line = line:gsub("%s+$", "") -- Trim trailing
        local is_empty = line:match("^%s*$")

        -- Indentation: Force Tabs
        while line:match("^%t*    ") do
            line = line:gsub("^(%t*)    ", "%1\t")
        end

        -- Semantic Fixes
        if line:match("%s[%a_][%a%d_]*%(%)") or line:match("^[%a_][%a%d_]*%(%)") then
             line = line:gsub("%(%)","(void)")
        end
        if line:match("^%s*return%s+[^%(].*;$") then
            local indent, val = line:match("^(%s*)return%s+(.-);$")
            if val and val ~= "" and not val:match("^%b()$") then
                line = indent .. "return (" .. val .. ");"
            end
        end

        -- Type-Name Tabbing & 42 Norm Structural Fixes
        local is_decl = false
        if not line:match("^#") and not line:match("^{") and not line:match("^}") then
            -- Match indentation, type (greedy, excluding ( and ,), and name+rest
            local indent, type, name_rest = line:match("^([%t%s]*)([^%(%,]+%S)%s+([%a_%*][%a%d_]*.*%;)")

            if indent and type and name_rest then
                local is_keyword = type:match("^return$") or type:match("^if$") or type:match("^while$") or type:match("^for$") or type:match("^switch$") or type:match("^else$")
                if not is_keyword then
                    is_decl = true

                    -- Split declaration and assignment (42 Norm: int i = 0; -> int i; i = 0;)
                    local name, val = name_rest:match("^([%a_%*][%a%d_]*)%s*=%s*(.-);")
                    if name and val then
                        table.insert(result, indent .. type .. "\t" .. name .. ";")
                        line = indent .. name .. " = " .. val .. ";"
                        is_decl = false -- Current line is now an assignment, not a declaration
                        last_was_decl = true -- Explicitly mark that a declaration just occurred
                    else
                        line = indent .. type .. "\t" .. name_rest
                    end
                end
            elseif line:match("^[%a_][%a%d_%*]+%s+[%a_][%a%d_]*%s*%(") then
                -- Functions at top level
                local type_func, name_rest_func = line:match("^([%a_][%a%d_%*]*.-)%s+([%a_][%a%d_].*)")
                if type_func and name_rest_func then
                    line = type_func .. "\t" .. name_rest_func
                end
            end
        end

        -- Newline after declarations (42 Norm)
        if last_was_decl and not is_decl and not is_empty and not line:match("^%s*}") and not line:match("^%s*{") then
            if #result > 0 and result[#result] ~= "" then
                table.insert(result, "")
            end
        end
        last_was_decl = is_decl

        -- Empty Line Logic
        if line:match("^{") then in_function = true end
        if line:match("^}") then in_function = false end

        local skip = false
        if in_function and is_empty then
            local prev = #result > 0 and result[#result] or ""
            local next_line = i < #lines and lines[i + 1] or ""
            if prev:match("^{") or next_line:match("^}") then skip = true end
        end
        if is_empty and #result > 0 and result[#result] == "" then skip = true end

        if not skip then
            table.insert(result, line)
        end
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result)
end

return M
