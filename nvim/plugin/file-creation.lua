local function create_new_file()
    vim.ui.input({ prompt = "Create new file (path/to/file): ", completion = "file" }, function(input)
        if input and input ~= "" then
            local path = vim.fn.expand(input)
            local dir = vim.fn.fnamemodify(path, ":h")
            
            -- Create directory if it doesn't exist
            if vim.fn.isdirectory(dir) == 0 then
                vim.fn.mkdir(dir, "p")
            end
            
            -- Open the file
            vim.cmd("edit " .. path)
        end
    end)
end

vim.api.nvim_create_user_command("NewFile", create_new_file, {})
vim.keymap.set("n", "<leader>nf", "<cmd>NewFile<cr>", { desc = "Create new file with directory prompt" })

return { create = create_new_file }
