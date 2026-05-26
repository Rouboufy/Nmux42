local bufnr = vim.api.nvim_get_current_buf()
local query_string = [[
    (declaration
        type: (_) @type
        declarator: (init_declarator
            declarator: (_) @name
            value: (_) @value)) @decl
]]

local parser = vim.treesitter.get_parser(bufnr, "c")
if not parser then
    print("No parser found for C")
    return
end
local tree = parser:parse()[1]
local root = tree:root()
local query = vim.treesitter.query.parse("c", query_string)

print("Starting debug...")
for id, node, _ in query:iter_captures(root, bufnr, 0, -1) do
    local name = query.captures[id]
    local text = vim.treesitter.get_node_text(node, bufnr)
    local s_r, s_c, e_r, e_c = node:range()
    print("Capture: " .. name .. " [" .. s_r .. ":" .. s_c .. " - " .. e_r .. ":" .. e_c .. "] -> " .. text)
end
print("Debug finished.")
