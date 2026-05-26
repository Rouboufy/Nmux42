local bufnr = vim.api.nvim_get_current_buf()
local query_string = [[
    (declaration
        type: (_) @type
        declarator: (init_declarator
            declarator: (_) @name
            value: (_) @value)) @decl
]]

local parser = vim.treesitter.get_parser(bufnr, "c")
local tree = parser:parse()[1]
local root = tree:root()
local query = vim.treesitter.query.parse("c", query_string)

local changes = {}
print("Iterating matches...")
for _, match, _ in query:iter_matches(root, bufnr, 0, -1) do
    local decl_node = nil
    local type_node = nil
    local name_node = nil
    local value_node = nil
    
    for id, nodes in pairs(match) do
        local name = query.captures[id]
        local node = nodes[1]
        if name == "decl" then decl_node = node
        elseif name == "type" then type_node = node
        elseif name == "name" then name_node = node
        elseif name == "value" then value_node = node end
    end
    
    if decl_node and type_node and name_node and value_node then
        print("Found decl_node!")
        local type_text = vim.treesitter.get_node_text(type_node, bufnr)
        local name_text = vim.treesitter.get_node_text(name_node, bufnr)
        local value_text = vim.treesitter.get_node_text(value_node, bufnr)
        
        local start_row, start_col, end_row, end_col = decl_node:range()
        print("Range: " .. start_row .. ":" .. start_col .. " - " .. end_row .. ":" .. end_col)
        
        table.insert(changes, {
            start_row = start_row,
            start_col = start_col,
            end_row = end_row,
            end_col = end_col,
            new_text = { type_text .. " " .. name_text .. ";", name_text .. " = " .. value_text .. ";" }
        })
    else
        print("Nodes missing: decl=" .. tostring(decl_node ~= nil) .. " type=" .. tostring(type_node ~= nil) .. " name=" .. tostring(name_node ~= nil) .. " value=" .. tostring(value_node ~= nil))
    end
end

for i = #changes, 1, -1 do
    local c = changes[i]
    print("Applying change to row " .. c.start_row)
    local status, err = pcall(vim.api.nvim_buf_set_text, bufnr, c.start_row, c.start_col, c.end_row, c.end_col, c.new_text)
    if not status then
        print("Error setting text: " .. tostring(err))
    end
end
print("Done.")
