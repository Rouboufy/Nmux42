local status, nf = pcall(require, "norm-format")
if status then
    nf.setup({
        format_on_save = true
    })
end
