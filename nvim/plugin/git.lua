-- ─────────────────────────────────────────────────────────────────────────────
-- git.lua  —  Nmux42 Git Integration
--
--  • gitsigns.nvim  : gutter signs, inline blame, hunk preview
--  • LazyGit        : Primary TUI (requires 'lazygit' binary)
--  • Custom Git TUI : Fallback 3-tab TUI (Status | Log | Diff)
--                     Works with git only — no external binary needed.
--
-- Keybinds (normal mode):
--   <leader>gg   Open Git TUI (LazyGit with fallback)
--   <leader>gl   Open Git Log TUI
--   <leader>gd   Open Git Diff TUI
--   <leader>gb   Toggle inline blame (gitsigns)
--   <leader>gp   Preview hunk inline (gitsigns)
--   ]h / [h      Next / Previous hunk (gitsigns)
-- ─────────────────────────────────────────────────────────────────────────────

-- ══════════════════════════════════════════════════════════════════════════════
-- 1. gitsigns.nvim  (gutter decorations + inline blame)
-- ══════════════════════════════════════════════════════════════════════════════
local gs_ok, gitsigns = pcall(require, "gitsigns")
if gs_ok then
    gitsigns.setup({
        signs = {
            add          = { text = "▎" },
            change       = { text = "▎" },
            delete       = { text = " " },
            topdelete    = { text = " " },
            changedelete = { text = "▎" },
            untracked    = { text = "▎" },
        },
        current_line_blame = true,
        current_line_blame_opts = {
            virt_text_pos = "right_align",
            delay = 600,
        },
        current_line_blame_formatter = "  <author>, <author_time:%Y-%m-%d> · <summary>",
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns
            local map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
            end
            map("n", "]h", function()
                if vim.wo.diff then return "]c" end
                vim.schedule(function() gs.next_hunk() end)
                return "<Ignore>"
            end, "Next Git Hunk")
            map("n", "[h", function()
                if vim.wo.diff then return "[c" end
                vim.schedule(function() gs.prev_hunk() end)
                return "<Ignore>"
            end, "Prev Git Hunk")
            map("n", "<leader>gb", gs.toggle_current_line_blame, "Toggle Inline Blame")
            map("n", "<leader>gp", gs.preview_hunk,              "Preview Hunk Inline")
            map("n", "<leader>gs", gs.stage_hunk,                "Stage Hunk")
            map("n", "<leader>gr", gs.reset_hunk,                "Reset Hunk")
            map("n", "<leader>gS", gs.stage_buffer,              "Stage Buffer")
            map("n", "<leader>gu", gs.undo_stage_hunk,           "Undo Stage Hunk")
            map("n", "<leader>gR", gs.reset_buffer,              "Reset Buffer")
            map("n", "<leader>gd", gs.diffthis,                  "Diff This")
            map("n", "<leader>gD", function() gs.diffthis('~') end, "Diff This (HEAD~1)")
            map("n", "<leader>gw", gs.toggle_word_diff,          "Toggle Word Diff")
            map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select Hunk")
        end,
    })
end

-- ══════════════════════════════════════════════════════════════════════════════
-- 2. Custom Git TUI (Fallback)
-- ══════════════════════════════════════════════════════════════════════════════
local state = {
    buf      = nil,
    win      = nil,
    tab      = "status",   -- "status" | "log" | "diff"
    cwd      = nil,        -- git repo root
    diff_file = nil,       -- file currently being diffed
    diff_mode = "unstaged", -- "unstaged" | "staged"
}

-- ── helpers ──────────────────────────────────────────────────────────────────

local function run_git(args, callback)
    local cmd = { "git" }
    if state.cwd then
        vim.list_extend(cmd, { "-C", state.cwd })
    end
    vim.list_extend(cmd, args)
    vim.system(cmd, { text = true }, function(obj)
        vim.schedule(function()
            local lines = {}
            local raw = (obj.stdout or "") .. (obj.stderr or "")
            for line in raw:gmatch("[^\r\n]+") do
                table.insert(lines, line)
            end
            callback(lines, obj.code)
        end)
    end)
end

local function git_root_sync(dir)
    local result = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })
    if vim.v.shell_error ~= 0 then return nil end
    return result[1]
end

local function set_lines(lines)
    if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then return end
    vim.bo[state.buf].modifiable = true
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
    vim.bo[state.buf].modifiable = false
end

local function hl(ns, group, line, col_start, col_end)
    pcall(vim.api.nvim_buf_add_highlight, state.buf, ns, group, line, col_start, col_end)
end

local function tab_header()
    local tabs = { status = "[1] Status", log = "[2] Log", diff = "[3] Diff" }
    local parts = {}
    for _, k in ipairs({ "status", "log", "diff" }) do
        if k == state.tab then
            table.insert(parts, "●" .. tabs[k])
        else
            table.insert(parts, "  " .. tabs[k])
        end
    end
    return "  " .. table.concat(parts, "  │  ")
end

-- ── Status tab ───────────────────────────────────────────────────────────────

local function render_status(lines, code)
    if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then return end

    local out = {
        tab_header(),
        "  ─────────────────────────────────────────────────────────",
        "",
    }

    if code ~= 0 then
        table.insert(out, "  ✗ Not a git repository (or git not found).")
        table.insert(out, "")
        table.insert(out, "  Run this inside a git repo to use the Git TUI.")
    else
        -- parse git status --short output
        local staged, unstaged, untracked = {}, {}, {}
        for _, l in ipairs(lines) do
            if #l >= 3 then
                local x = l:sub(1, 1)
                local y = l:sub(2, 2)
                local file = vim.trim(l:sub(4))
                if x ~= " " and x ~= "?" then
                    table.insert(staged,   { file = file, x = x, y = y })
                end
                if y ~= " " and y ~= "?" then
                    table.insert(unstaged, { file = file, x = x, y = y })
                end
                if x == "?" then
                    table.insert(untracked, { file = file })
                end
            end
        end

        if #staged == 0 and #unstaged == 0 and #untracked == 0 then
            table.insert(out, "  ✓ Working tree clean — nothing to commit.")
        else
            if #staged > 0 then
                table.insert(out, "  ── Staged ─────────────────────────────── (u = unstage)")
                for _, f in ipairs(staged) do
                    table.insert(out, "    " .. f.x .. "  " .. f.file)
                end
                table.insert(out, "")
            end
            if #unstaged > 0 then
                table.insert(out, "  ── Modified ─────────────────────────── (s = stage, d = diff)")
                for _, f in ipairs(unstaged) do
                    table.insert(out, "    " .. f.y .. "  " .. f.file)
                end
                table.insert(out, "")
            end
            if #untracked > 0 then
                table.insert(out, "  ── Untracked ───────────────────────────── (s = stage all)")
                for _, f in ipairs(untracked) do
                    table.insert(out, "    ?  " .. f.file)
                end
                table.insert(out, "")
            end
        end
    end

    table.insert(out, "")
    table.insert(out, "  ─────────────────────────────────────────────────────────")
    table.insert(out, "  [s] Stage  [u] Unstage  [c] Commit  [p] Push  [P] Pull  [r] Refresh  [q] Close")

    set_lines(out)

    -- syntax highlights
    local ns = vim.api.nvim_create_namespace("git_tui_hl")
    vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
    hl(ns, "Title",   0, 0, -1)
    hl(ns, "Comment", 1, 0, -1)
    for i, l in ipairs(out) do
        local li = i - 1
        if l:match("^%s+──") then
            hl(ns, "Special", li, 0, -1)
        elseif l:match("^%s+✓") then
            hl(ns, "DiagnosticOk", li, 0, -1)
        elseif l:match("^%s+✗") then
            hl(ns, "ErrorMsg", li, 0, -1)
        elseif l:match("^%s+[MADRC]%s") then
            hl(ns, "DiagnosticOk", li, 0, -1)   -- staged = green
        elseif l:match("^%s+[MD]%s") then
            hl(ns, "DiagnosticWarn", li, 0, -1)  -- modified = yellow
        elseif l:match("^%s+%?%s") then
            hl(ns, "Comment", li, 0, -1)          -- untracked = grey
        elseif l:match("^%s+%[") and li == #out - 1 then
            hl(ns, "Comment", li, 0, -1)
        end
    end
end

-- ── Log tab ──────────────────────────────────────────────────────────────────

local function render_log(lines, code)
    if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then return end

    local out = {
        tab_header(),
        "  ─────────────────────────────────────────────────────────",
        "",
    }
    if code ~= 0 or #lines == 0 then
        table.insert(out, "  No commits found, or not a git repository.")
    else
        for _, l in ipairs(lines) do
            table.insert(out, "  " .. l)
        end
    end
    table.insert(out, "")
    table.insert(out, "  ─────────────────────────────────────────────────────────")
    table.insert(out, "  [Enter] Show commit  [r] Refresh  [q] Close")

    set_lines(out)

    local ns = vim.api.nvim_create_namespace("git_tui_hl")
    vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
    hl(ns, "Title",   0, 0, -1)
    hl(ns, "Comment", 1, 0, -1)
    for i, l in ipairs(out) do
        local li = i - 1
        if l:match("%s[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]") then
            hl(ns, "Identifier", li, 0, 16)
        end
        if l:match("%(HEAD") or l:match("origin/") then
            hl(ns, "DiagnosticOk", li, 0, -1)
        end
        if l:match("^%s+%[") and li == #out - 1 then
            hl(ns, "Comment", li, 0, -1)
        end
        if l:match("^%s+──") then
            hl(ns, "Comment", li, 0, -1)
        end
    end
end

-- ── Diff tab ─────────────────────────────────────────────────────────────────

local function render_diff(lines, code)
    if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then return end

    local title = state.diff_mode == "staged" and "Staged diff" or "Unstaged diff"
    if state.diff_file then title = title .. ": " .. state.diff_file end

    local out = {
        tab_header(),
        "  ─── " .. title .. " ──────────────────────────────────────",
        "",
    }

    if code ~= 0 and #lines == 0 then
        table.insert(out, "  No diff available.")
    elseif #lines == 0 then
        table.insert(out, "  No changes.")
    else
        for _, l in ipairs(lines) do
            table.insert(out, l)
        end
    end

    table.insert(out, "")
    table.insert(out, "  ─────────────────────────────────────────────────────────")
    table.insert(out, "  [S] Staged diff  [U] Unstaged diff  [r] Refresh  [q] Close")

    set_lines(out)

    local ns = vim.api.nvim_create_namespace("git_tui_hl")
    vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
    hl(ns, "Title",   0, 0, -1)
    hl(ns, "Comment", 1, 0, -1)
    for i, l in ipairs(out) do
        local li = i - 1
        if l:match("^%+%+%+") or l:match("^%-%-%-") or l:match("^diff ") or l:match("^index ") then
            hl(ns, "Title", li, 0, -1)
        elseif l:sub(1, 1) == "+" then
            hl(ns, "DiagnosticOk", li, 0, -1)
        elseif l:sub(1, 1) == "-" then
            hl(ns, "DiagnosticError", li, 0, -1)
        elseif l:match("^@@") then
            hl(ns, "DiagnosticInfo", li, 0, -1)
        elseif l:match("^%s+──") or l:match("^%s+%[") then
            hl(ns, "Comment", li, 0, -1)
        end
    end
end

-- ── Master render dispatcher ──────────────────────────────────────────────────

local function render()
    if state.tab == "status" then
        set_lines({ tab_header(), "  ───────────────────────────────────", "", "  Loading git status…" })
        run_git({ "status", "--short" }, render_status)
    elseif state.tab == "log" then
        set_lines({ tab_header(), "  Loading log…" })
        run_git({
            "log", "--oneline", "--graph", "--decorate", "--all",
            "--format=%C(auto)%h %d %s  (%cr) <%an>",
            "-60"
        }, render_log)
    elseif state.tab == "diff" then
        set_lines({ tab_header(), "  Loading diff…" })
        local args = { "diff" }
        if state.diff_mode == "staged" then
            table.insert(args, "--cached")
        end
        if state.diff_file then
            table.insert(args, "--")
            table.insert(args, state.diff_file)
        end
        run_git(args, render_diff)
    end
end

-- ── Helpers for cursor interaction ───────────────────────────────────────────

local function file_under_cursor()
    local line = vim.api.nvim_get_current_line()
    -- Matches "    M  file.ext" or "    ?  file.ext"
    local file = line:match("^%s+%S%s+(.+)$")
    return file and vim.trim(file) or nil
end

local function hash_under_cursor()
    local line = vim.api.nvim_get_current_line()
    return line:match("%s([a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]+)")
end

-- ── Open the TUI ─────────────────────────────────────────────────────────────

local function open_git_ui_internal(initial_tab)
    local bufdir = vim.fn.expand("%:p:h")
    if bufdir == "" or not vim.uv.fs_stat(bufdir) then
        bufdir = vim.fn.getcwd()
    end
    local root = git_root_sync(bufdir)
    state.cwd = root or bufdir
    state.tab = initial_tab or "status"
    state.diff_file = nil
    state.diff_mode = "unstaged"

    local width  = math.min(88, vim.o.columns - 4)
    local height = math.floor(vim.o.lines * 0.85)
    local row    = math.floor((vim.o.lines - height) / 2)
    local col    = math.floor((vim.o.columns - width) / 2)

    local repo_name = root and vim.fn.fnamemodify(root, ":t") or "?"
    state.buf = vim.api.nvim_create_buf(false, true)
    state.win = vim.api.nvim_open_win(state.buf, true, {
        relative  = "editor",
        width     = width, height = height,
        row       = row,   col    = col,
        style     = "minimal",
        border    = "rounded",
        title     = "  Git UI  —  " .. repo_name .. "  ",
        title_pos = "center",
    })

    vim.bo[state.buf].buftype   = "nofile"
    vim.bo[state.buf].bufhidden = "wipe"
    vim.bo[state.buf].swapfile  = false
    vim.bo[state.buf].filetype  = "gitui"
    vim.wo[state.win].wrap      = false
    vim.wo[state.win].cursorline = true

    -- Bindings inside TUI
    local map = function(k, fn, desc)
        vim.keymap.set("n", k, fn, { buffer = state.buf, silent = true, desc = desc })
    end
    map("q",     function() pcall(vim.api.nvim_win_close, state.win, true) end, "Close")
    map("<Esc>", function() pcall(vim.api.nvim_win_close, state.win, true) end, "Close")
    map("r",     render,                                                          "Refresh")
    map("<Tab>", function()
        local order = { "status", "log", "diff" }
        for i, t in ipairs(order) do
            if t == state.tab then
                state.tab = order[(i % #order) + 1]
                break
            end
        end
        render()
    end, "Next Tab")
    map("1", function() state.tab = "status"; render() end, "Status Tab")
    map("2", function() state.tab = "log";    render() end, "Log Tab")
    map("3", function() state.tab = "diff";   render() end, "Diff Tab")

    map("s", function()
        local file = file_under_cursor()
        run_git(file and { "add", file } or { "add", "-A" }, function(_, code)
            vim.notify(code == 0 and "Staged successfully" or "Stage failed", code == 0 and 2 or 3)
            render()
        end)
    end, "Stage")
    map("u", function()
        local file = file_under_cursor()
        if file then
            run_git({ "restore", "--staged", file }, function(_, code)
                vim.notify(code == 0 and "Unstaged successfully" or "Unstage failed", code == 0 and 2 or 3)
                render()
            end)
        end
    end, "Unstage")
    map("d", function()
        local file = file_under_cursor()
        state.diff_file = file
        state.diff_mode = "unstaged"
        state.tab = "diff"
        render()
    end, "Diff file")
    map("c", function()
        vim.ui.input({ prompt = "Commit message: " }, function(msg)
            if msg and msg ~= "" then
                run_git({ "commit", "-m", msg }, function(lines, code)
                    vim.notify(code == 0 and ("Committed: " .. msg) or table.concat(lines, " "), code == 0 and 2 or 3)
                    render()
                end)
            end
        end)
    end, "Commit")
    map("p", function()
        vim.notify("Pushing…", 2)
        run_git({ "push" }, function(lines, code)
            vim.notify(code == 0 and "Push successful" or "Push failed", code == 0 and 2 or 3)
            render()
        end)
    end, "Push")
    map("P", function()
        vim.notify("Pulling…", 2)
        run_git({ "pull" }, function(lines, code)
            vim.notify(code == 0 and "Pull successful" or "Pull failed", code == 0 and 2 or 3)
            render()
        end)
    end, "Pull")
    map("<CR>", function()
        if state.tab == "log" then
            local hash = hash_under_cursor()
            if hash then
                run_git({ "show", "--stat", hash }, function(lines)
                    local pbuf = vim.api.nvim_create_buf(false, true)
                    vim.api.nvim_buf_set_lines(pbuf, 0, -1, false, lines)
                    vim.bo[pbuf].modifiable = false
                    vim.api.nvim_open_win(pbuf, true, { relative = "editor", width = 80, height = 20, row = 5, col = 5, border = "rounded", title = " " .. hash .. " " })
                    vim.keymap.set("n", "q", "<cmd>q<cr>", { buffer = pbuf })
                end)
            end
        elseif state.tab == "status" then
            local file = file_under_cursor()
            if file then state.diff_file = file; state.tab = "diff"; render() end
        end
    end, "Details")
    map("S", function() state.diff_mode = "staged"; render() end, "Staged diff")
    map("U", function() state.diff_mode = "unstaged"; render() end, "Unstaged diff")

    render()
end

-- ── Public API ───────────────────────────────────────────────────────────────

local function open_git_ui()
    -- If lazygit is installed, use it. Otherwise use custom TUI.
    if vim.fn.executable("lazygit") == 1 then
        vim.cmd("LazyGit")
    else
        open_git_ui_internal("status")
    end
end

vim.api.nvim_create_user_command("GitUI", open_git_ui, {})
vim.api.nvim_create_user_command("NmuxGit", function() open_git_ui_internal("status") end, {})

vim.keymap.set("n", "<leader>gg", open_git_ui, { desc = "Open Git TUI (LazyGit fallback)" })
vim.keymap.set("n", "<leader>gl", function() open_git_ui_internal("log") end, { desc = "Open Git Log" })
vim.keymap.set("n", "<leader>gd", function() open_git_ui_internal("diff") end, { desc = "Open Git Diff" })

-- LazyGit specific filters
vim.keymap.set("n", "<leader>gf", function()
    if vim.fn.executable("lazygit") == 1 then
        vim.cmd("LazyGitFilter")
    else
        vim.notify("LazyGit binary not found. This feature requires the 'lazygit' CLI.", 3)
    end
end, { desc = "LazyGit File Filter" })

vim.keymap.set("n", "<leader>gc", function()
    if vim.fn.executable("lazygit") == 1 then
        vim.cmd("LazyGitFilterCurrentFile")
    else
        vim.notify("LazyGit binary not found. This feature requires the 'lazygit' CLI.", 3)
    end
end, { desc = "LazyGit Current File History" })
