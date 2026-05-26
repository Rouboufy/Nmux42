local M = {}
local plug_dir = vim.fn.stdpath("data") .. "/plugins"

local function ensure(spec)
    local repo = type(spec) == "string" and spec or spec[1]
    local name = repo:match(".+/(.+)$")
    local path = plug_dir .. "/" .. name

    if not vim.uv.fs_stat(path) then
        vim.fn.mkdir(plug_dir, "p")
        local cmd = { "git", "clone", "--depth=1" }
        if spec.branch then
            table.insert(cmd, "-b")
            table.insert(cmd, spec.branch)
        end
        table.insert(cmd, "https://github.com/" .. repo)
        table.insert(cmd, path)
        print("Installing " .. name .. "...")
        vim.fn.system(cmd)
    end

    vim.opt.rtp:prepend(path)
    local after_path = path .. "/after"
    if vim.uv.fs_stat(after_path) then
        vim.opt.rtp:append(after_path)
    end
    local lua_path = path .. "/lua"
    if vim.uv.fs_stat(lua_path) then
        package.path = package.path .. ";" .. lua_path .. "/?.lua;" .. lua_path .. "/?/init.lua"
    end
end

function M.ensure_plugin(spec)
    ensure(spec)
end

function M.setup()
    local list = require("plugin-list")

    -- Load active theme spec dynamically
    local theme_ok, theme_specs = pcall(require, "plugins.theme")
    if theme_ok and type(theme_specs) == "table" then
        for _, spec in ipairs(theme_specs) do
            if spec[1] and spec[1] ~= "LazyVim/LazyVim" then
                table.insert(list, spec)
            end
        end
    end

    for _, spec in ipairs(list) do
        ensure(spec)
    end
end

return M
