local status_mason, mason = pcall(require, "mason")
if status_mason then
    mason.setup()
end
