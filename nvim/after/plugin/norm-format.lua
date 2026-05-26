vim.notify("Nmux42: Loading Norm-format config...", vim.log.levels.INFO)
local status, nf = pcall(require, "norm-format")
if status then
    vim.notify("Nmux42: Norm-format loaded successfully", vim.log.levels.INFO)
    nf.setup({
        format_on_save = true
    })
else
    vim.notify("Nmux42: Failed to load Norm-format plugin: " .. tostring(nf), vim.log.levels.ERROR)
end
