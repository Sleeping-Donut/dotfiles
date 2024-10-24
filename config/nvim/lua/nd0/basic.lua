-- vim.cmd.colorscheme("habamax")
vim.cmd.colorscheme("desert")

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.syntax.enable = true
vim.opt.syntax.on = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"
vim.opt.cursorline = true;

vim.opt.encoding = "utf-8"
vim.scriptencoding = "utf-8"

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Remaps

vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
-- filetype plugin indent on

-- Load default keymap descriptions
local _, ok = pcall(require, "nd0.default_keymap_descriptions")
if not ok then print("Error: Failed to load module nd0.default_keymap_descriptions") end

