print("INIT_DEBUG: Loading Norm-format config")
local status, nf = pcall(require, "norm-format")
if status then
    print("INIT_DEBUG: Norm-format loaded")
    nf.setup({
        format_on_save = true
    })
else
    print("INIT_DEBUG: FAILED to load Norm-format plugin: " .. tostring(nf))
end
