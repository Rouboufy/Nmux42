local n = require("diagnostics.norminette")
print("Manually running norminette diagnostics...")
n.run()
vim.wait(2000, function() return false end) -- Wait for job to finish
local diagnostics = vim.diagnostic.get(0)
print("Found " .. #diagnostics .. " diagnostics.")
for _, d in ipairs(diagnostics) do
    print("Diag: [" .. d.lnum .. ":" .. d.col .. "] " .. d.message)
end
