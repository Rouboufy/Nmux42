local status, nf = pcall(require, "norm-format-fixed")
if status then
    nf.setup({
        format_on_save = true
    })
end
