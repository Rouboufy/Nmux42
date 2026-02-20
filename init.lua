vim.opt.termguicolors = true
print("I use Neovim btw")
vim.env.PATH = vim.fn.expand("~/.cargo/bin") .. ":" .. vim.env.PATH

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.shiftwidth = 4

-- Keybinds
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)

-- Lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    config = function()
      vim.cmd.colorscheme("tokyonight")
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    end
  },

  -- Lualine
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      theme = 'tokyonight'
    }
  },

  -- Completion
  {
    "saghen/blink.cmp",
    version = "*",
    opts = {
      keymap = { preset = "default" },
      appearance = {
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
  },

  -- Harpoon
  {
    "ThePrimeagen/harpoon",
    config = function()
      local harpoon = require("harpoon")
      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
      vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
    end,
  },

  -- Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<M-l>", -- Alt + l to accept suggestion
          },
        },
        panel = { enabled = false },
      })
    end,
  },

  -- LSP and Mason
  { "neovim/nvim-lspconfig" },
  { "mason-org/mason.nvim" },

  -- One-liners/Utils
  { "tpope/vim-fugitive" },
  { "ojroques/nvim-osc52" },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep)
      vim.keymap.set("n", "<leader>fb", builtin.buffers)
      vim.keymap.set("n", "<leader>fh", builtin.help_tags)
    end,
  },

  -- Tmux Navigator
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Window Left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Window Down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Window Up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Window Right" },
    },
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "Python", "Typescript" },
      auto_install = true,
    },
    config = function(_, opts)
      local status_ok, configs = pcall(require, "nvim-treesitter.configs")
      if status_ok then
        configs.setup(opts)
      end
    end,
  },
})

-- Mason Setup
require("mason").setup()

-- LSP Enable (Neovim 0.11+ feature)
if vim.lsp.enable then
  vim.lsp.enable({"clangd", "ts_ls", "lua_ls", "python", "html.lua"})
end
