local ok, neotree = pcall(require, "neo-tree")
if not ok then
    return
end

neotree.setup({
    close_if_last_window = true,
    filesystem = {
        filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
        },
        follow_current_file = {
            enabled = true,
        },
    },
})
