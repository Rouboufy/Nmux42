-- ─────────────────────────────────────────────────────────────
-- vim_bindings.lua — Interactive Vim Motions & Nmux42 Keybinds
-- Opens a scrollable floating window with two tabs:
--   [1] Vim Motions  — standard Vim navigation & editing
--   [2] Nmux42 Keys  — all custom leader keybindings
-- ─────────────────────────────────────────────────────────────

local VIM_MOTIONS = {
    "  ╭──────────────────────────────────────────────────────────────╮",
    "  │               ⚡  VIM MOTIONS REFERENCE CARD                │",
    "  ╰──────────────────────────────────────────────────────────────╯",
    "",
    "  ── MODES ──────────────────────────────────────────────────────",
    "  i / I      Insert mode (before cursor / at line start)",
    "  a / A      Append mode (after cursor / at line end)",
    "  o / O      Open new line below / above and insert",
    "  v / V      Visual mode / Visual Line mode",
    "  <C-v>      Visual Block mode (column editing)",
    "  Esc        Return to Normal mode",
    "  R          Replace mode (overwrite text)",
    "",
    "  ── NAVIGATION ─────────────────────────────────────────────────",
    "  h j k l    Left / Down / Up / Right",
    "  w / W      Jump to next word start (word / WORD)",
    "  e / E      Jump to next word end   (word / WORD)",
    "  b / B      Jump back word start    (word / WORD)",
    "  0 / ^      Start of line / First non-blank char",
    "  $          End of line",
    "  gg / G     First line / Last line of file",
    "  {N}G       Jump to line N (e.g. 42G)",
    "  <C-d>      Scroll down half a page (cursor stays centered)",
    "  <C-u>      Scroll up half a page   (cursor stays centered)",
    "  <C-f>/<C-b>  Scroll full page down / up",
    "  %          Jump to matching bracket/paren/brace",
    "  *          Search forward for word under cursor",
    "  #          Search backward for word under cursor",
    "  n / N      Next / Previous search match",
    "  ''         Jump back to previous position",
    "  zz         Center screen on cursor",
    "  zt / zb    Scroll so cursor is at Top / Bottom",
    "",
    "  ── TEXT OBJECTS ────────────────────────────────────────────────",
    "  iw / aw    Inner word / A word (incl. surrounding space)",
    "  i\" / a\"    Inside quotes / Including quotes",
    "  i( / a(    Inside parens / Including parens",
    "  i{ / a{    Inside braces / Including braces",
    "  i[ / a[    Inside brackets / Including brackets",
    "  it / at    Inside tag / Including tag (HTML/XML)",
    "  ip / ap    Inner paragraph / A paragraph",
    "  is / as    Inner sentence / A sentence",
    "",
    "  ── OPERATORS (combine with motion or text object) ───────────────",
    "  d{motion}  Delete  (e.g. dw, d$, dip, d3j)",
    "  c{motion}  Change  (delete + insert mode)",
    "  y{motion}  Yank    (copy)",
    "  >{motion}  Indent right",
    "  <{motion}  Indent left",
    "  ={motion}  Auto-indent",
    "  gU{motion} Uppercase",
    "  gu{motion} Lowercase",
    "  g~{motion} Toggle case",
    "",
    "  ── EDITING SHORTCUTS ───────────────────────────────────────────",
    "  x / X      Delete char under cursor / before cursor",
    "  s / S      Substitute char / whole line",
    "  dd / D     Delete line / Delete to end of line",
    "  yy / Y     Yank line / Yank to end of line",
    "  p / P      Paste after cursor / before cursor",
    "  u          Undo",
    "  <C-r>      Redo",
    "  .          Repeat last change",
    "  J          Join line below to current line",
    "  r{char}    Replace single character with {char}",
    "  ~          Toggle case of character under cursor",
    "  >>  /  <<  Indent / Unindent current line",
    "  =G         Auto-indent from cursor to end of file",
    "",
    "  ── SEARCH & REPLACE ────────────────────────────────────────────",
    "  /pattern   Search forward  (n=next, N=prev)",
    "  ?pattern   Search backward",
    "  :%s/old/new/g      Replace all in file",
    "  :%s/old/new/gc     Replace all with confirmation",
    "  :s/old/new/g       Replace all in current line",
    "",
    "  ── MARKS & JUMPS ───────────────────────────────────────────────",
    "  m{a-z}     Set local mark  (m{A-Z} for global mark)",
    "  `{mark}    Jump to exact mark position",
    "  '{mark}    Jump to mark's line start",
    "  <C-o>      Jump to previous location in jump list",
    "  <C-i>      Jump to next location in jump list",
    "",
    "  ── MACROS ──────────────────────────────────────────────────────",
    "  q{a-z}     Start recording macro into register {a-z}",
    "  q          Stop recording macro",
    "  @{a-z}     Replay macro from register {a-z}",
    "  @@         Repeat last macro",
    "  {N}@{a-z}  Replay macro N times",
    "",
    "  ── WINDOWS & SPLITS ────────────────────────────────────────────",
    "  <C-w>s     Horizontal split",
    "  <C-w>v     Vertical split",
    "  <C-w>h/j/k/l   Move between splits",
    "  <C-w>q     Close current split",
    "  <C-w>=     Equalize all split sizes",
    "  <C-w>|     Maximize current split width",
    "  <C-w>_     Maximize current split height",
    "",
    "  ── COMMAND MODE ────────────────────────────────────────────────",
    "  :w         Save file",
    "  :q         Quit",
    "  :wq / :x   Save and quit",
    "  :q!        Quit without saving",
    "  :e {file}  Open file",
    "  :bn / :bp  Next / Previous buffer",
    "  :bd        Delete (close) buffer",
    "  :noh       Clear search highlight",
    "  :set nu    Toggle line numbers",
    "  :!{cmd}    Run shell command",
}

local NMUX_KEYS = {
    "  ╭──────────────────────────────────────────────────────────────╮",
    "  │              ⚙  NMUX42 CUSTOM KEYBINDINGS                   │",
    "  ╰──────────────────────────────────────────────────────────────╯",
    "  Leader key = <Space>",
    "",
    "  ── FILE & NAVIGATION ───────────────────────────────────────────",
    "  <leader>e      Toggle Neo-tree file explorer",
    "  <leader>cd     Open NetRW file browser",
    "  <leader>ff     Telescope: fuzzy find files",
    "  <leader>fo     Telescope: recent files",
    "  <leader>fg     Telescope: live grep (ripgrep)",
    "  <leader>fs     Telescope: search word under cursor",
    "  <leader>fb     Telescope: open buffers",
    "  <leader>fh     Telescope: help tags",
    "  <leader>fc     Telescope: files matching current filename",
    "  <leader>fi     Telescope: search in nvim config",
    "  <leader>db     Go back to welcome dashboard",
    "",
    "  ── GIT ─────────────────────────────────────────────────────────",
    "  <leader>gg     Open Git TUI (LazyGit with fallback)",
    "  <leader>gl     Open Git Log TUI",
    "  <leader>gd     Open Git Diff TUI",
    "  <leader>gf     LazyGit: file log / filter",
    "  <leader>gc     LazyGit: current file history",
    "  <leader>gs     Gitsigns: stage hunk under cursor",
    "  <leader>gr     Gitsigns: reset hunk under cursor",
    "  <leader>gS     Gitsigns: stage entire buffer",
    "  <leader>gu     Gitsigns: undo last stage",
    "  <leader>gR     Gitsigns: reset entire buffer",
    "  <leader>gp     Gitsigns: preview hunk inline",
    "  <leader>gb     Gitsigns: toggle inline blame",
    "  <leader>gw     Gitsigns: toggle word diff",
    "  ]h / [h        Jump to next / prev git hunk",
    "  ih             Text object: select git hunk (o/x mode)",
    "",
    "  ── EDITING ─────────────────────────────────────────────────────",
    "  <leader>s      Replace all occurrences of word under cursor",
    "  <leader>d      Delete without yanking (\"_d)",
    "  <leader>p      Paste without overwriting clipboard (\"_dP)",
    "  <leader>x      Make current file executable (chmod +x)",
    "  <leader>u      Toggle Undotree (visual undo history)",
    "  <leader>dg     Generate docstring (DogeGenerate)",
    "  <leader>cc     PHP CS Fixer: format current file",
    "  J / K  (v)     Move selected lines down / up",
    "",
    "  ── HARPOON ─────────────────────────────────────────────────────",
    "  <leader>a      Add current file to Harpoon",
    "  <C-e>          Toggle Harpoon quick menu",
    "  <C-h/t/n/s>    Jump to Harpoon slots 1 / 2 / 3 / 4",
    "",
    "  ── TERMINAL ────────────────────────────────────────────────────",
    "  <leader>ot     Toggle bottom terminal split",
    "  <leader>oT     Toggle vertical terminal split",
    "  <leader>ft     Toggle floating terminal (Flterm)",
    "  Esc Esc        Exit terminal mode",
    "",
    "  ── LSP ─────────────────────────────────────────────────────────",
    "  gd             Go to definition",
    "  gD             Go to declaration",
    "  gr             Find all references",
    "  gi             Go to implementation",
    "  K              Show hover documentation",
    "  <leader>rn     Rename symbol",
    "  <leader>ca     Code action",
    "  <leader>li     LSP info / checkhealth",
    "  <C-j> / <C-k>  Next / Prev quickfix item",
    "",
    "  ── YANK & CLIPBOARD ────────────────────────────────────────────",
    "  <leader>y (n)  OSC Yank: copy with operator (SSH/tmux safe)",
    "  <leader>y (v)  OSC Yank: copy visual selection",
    "",
    "  ── TOOLS ───────────────────────────────────────────────────────",
    "  <leader>Ja     Japonette TUI (Active Campus tab)",
    "  <leader>Jf     Japonette TUI (Friends Watchlist tab)",
    "  <leader>th     Theme Selector (live preview + tmux sync)",
    "  <leader>hk     This keybindings reference menu",
    "  <leader>hp     Plugins manager / list",
    "  <leader>mm     Run make in current directory",
    "  <leader>rl     Reload Neovim config (source init.lua)",
    "  <leader><<     Source current file",
    "",
    "  ── TMUX (outside Neovim) ───────────────────────────────────────",
    "  Ctrl-a         Tmux prefix",
    "  prefix + |     Split pane vertically",
    "  prefix + -     Split pane horizontally",
    "  prefix + x     Kill current pane",
    "  prefix + k     Kill current window",
    "  Alt+h/j/k/l    Navigate panes (no prefix needed)",
    "  Alt+1..9       Jump to window 1–9",
    "  Alt+Left/Right Previous / Next window",
    "  prefix + r     Reload tmux config",
    "  prefix + C     New session",
    "  prefix + K     Kill session",
}

-- ── Renderer ─────────────────────────────────────────────────
local state = { active_tab = "vim", buf = nil, win = nil }

local function open_bindings_window()
    local width  = math.min(72, vim.o.columns - 4)
    local height = math.floor(vim.o.lines * 0.85)
    local row    = math.floor((vim.o.lines - height) / 2)
    local col    = math.floor((vim.o.columns - width) / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative    = "editor",
        width       = width,
        height      = height,
        row         = row,
        col         = col,
        style       = "minimal",
        border      = "rounded",
        title       = "  Neovim Bindings Reference ",
        title_pos   = "center",
    })
    return buf, win
end

local function render()
    if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then return end

    local tab_vim  = state.active_tab == "vim"
    local tab1_lbl = tab_vim and "●[1] Vim Motions " or "  [1] Vim Motions "
    local tab2_lbl = tab_vim and "  [2] Nmux42 Keys" or "●[2] Nmux42 Keys"

    local header = {
        "  " .. tab1_lbl .. " │ " .. tab2_lbl,
        "  ────────────────────────────────────────────────────────────",
        "",
    }

    local content = tab_vim and VIM_MOTIONS or NMUX_KEYS
    local lines = {}
    for _, l in ipairs(header) do table.insert(lines, l) end
    for _, l in ipairs(content) do table.insert(lines, l) end
    table.insert(lines, "")
    table.insert(lines, "  [Tab]/[1]/[2] Switch tab  │  [/] Search  │  [q/Esc] Close")

    vim.bo[state.buf].modifiable = true
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
    vim.bo[state.buf].modifiable = false
    vim.api.nvim_win_set_cursor(state.win, { 1, 0 })

    -- Highlight header
    local ns = vim.api.nvim_create_namespace("vimbindings_hl")
    vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
    vim.api.nvim_buf_add_highlight(state.buf, ns, "Title",   0, 0, -1)
    vim.api.nvim_buf_add_highlight(state.buf, ns, "Comment", 1, 0, -1)
    -- Highlight section headers (lines starting with "  ──")
    for i, l in ipairs(lines) do
        if l:match("^%s+──") then
            vim.api.nvim_buf_add_highlight(state.buf, ns, "Special", i - 1, 0, -1)
        elseif l:match("^%s+╭") or l:match("^%s+│") or l:match("^%s+╰") then
            vim.api.nvim_buf_add_highlight(state.buf, ns, "DiagnosticInfo", i - 1, 0, -1)
        elseif l:match("^%s+%[") and i == #lines then
            vim.api.nvim_buf_add_highlight(state.buf, ns, "Comment", i - 1, 0, -1)
        end
    end
end

local function open_vim_bindings()
    state.buf, state.win = open_bindings_window()
    vim.bo[state.buf].buftype   = "nofile"
    vim.bo[state.buf].bufhidden = "wipe"
    vim.bo[state.buf].swapfile  = false
    vim.bo[state.buf].filetype = "vimbindings"

    local map = function(k, fn, desc)
        vim.keymap.set("n", k, fn, { buffer = state.buf, silent = true, desc = desc })
    end

    map("q",     function() pcall(vim.api.nvim_win_close, state.win, true) end, "Close")
    map("<Esc>", function() pcall(vim.api.nvim_win_close, state.win, true) end, "Close")

    map("<Tab>", function()
        state.active_tab = state.active_tab == "vim" and "nmux" or "vim"
        render()
    end, "Switch tab")
    map("1", function() state.active_tab = "vim";  render() end, "Vim Motions tab")
    map("2", function() state.active_tab = "nmux"; render() end, "Nmux42 Keys tab")

    -- Search within the buffer using built-in /
    map("/", function()
        vim.api.nvim_feedkeys("/", "n", false)
    end, "Search in buffer")

    render()
end

-- ── Commands & Keymaps ───────────────────────────────────────
vim.api.nvim_create_user_command("VimBindings", open_vim_bindings, {})
vim.keymap.set("n", "<leader>vb", "<cmd>VimBindings<CR>", { desc = "Open Vim Bindings Reference" })
vim.keymap.set("n", "<leader>?",  "<cmd>VimBindings<CR>", { desc = "Open Vim Bindings Reference" })
