vim.cmd.colorscheme("habamax") -- fallback colorscheme

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

-- vim.opt.syntax.enable = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.colorcolumn = "80"
vim.opt.cursorline = true

-- vim.opt.encoding = "utf-8"
-- vim.scriptencoding = "utf-8"

vim.opt.mouse = ""

vim.opt.updatetime = 100

vim.opt.list = true
vim.opt.listchars = {
	tab = "» ",       -- Show tabs as »
	trail = "·",      -- Show trailing spaces as dots
	nbsp = "␣",       -- Show non-breaking spaces
	extends = "→",    -- Show if line continues off-screen (right)
	precedes = "←",   -- Show if line continues off-screen (left)
	eol = "↵",
}

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Make inlay hints look like comments (subtle and out of the way)
vim.api.nvim_set_hl(0, "LspInlayHint", { link = "Comment" })
-- vim.cmd("hi! LspInlayHint guifg=#403d52 guibg=#1f1d2e") -- Keep cause I might change my mind

vim.diagnostic.config({
	virtual_text = true, -- Show text at the end of the line
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "solid",
		-- source = true,	-- Show which LSP
	},
})
-- TODO: use these diagnostics somewhere
-- vim.diagnostic.setqflist()
-- vim.diagnostic.setloclist()
-- Remaps

vim.keymap.set("n", "<Space>", "<Nop>", {desc = "Prevent moving cursor with <Space> in Normal"})

vim.keymap.set("n", "<C-u>", "<C-u>zz", {desc = "Jump up and center"})
vim.keymap.set("n", "<C-d>", "<C-d>zz", {desc = "Jump down and center"})

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, {desc = "Open netrw"})

vim.keymap.set("n", "<leader>bw", vim.cmd.write, {desc = "Write buffer"})

vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], {desc = "Copy to clipboard"})
vim.keymap.set("n", "<leader>Y", [["+Y"]], {desc = "Copy to clipboard"})

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]], {desc = "Delete to black hole"})

vim.keymap.set("i", "<C-c>", "<Esc>", {desc = "C-c escapes when insert mode"})

vim.keymap.set("n", "<leader><leader>", function() dofile(vim.fn.expand("%")) end, {desc = "Source current buffer"})
vim.keymap.set("n", "<leader>sc", function()
	for _,mod in ipairs({ "nd0", "nd0.lsp", "nd0.plugins", "qpack", "diffdirs"}) do
		package.loaded[mod] = nil
	end
	vim.cmd.source(vim.env.MYVIMRC)
	vim.print("Sourced config: "..vim.env.MYVIMRC)
end, {desc = "Source init.lua"})

vim.keymap.set("n", "<leader>ld", function()
	local dir = vim.fn.expand("%:p:h")
	vim.api.nvim_set_current_dir(dir)
end, {desc = "Load current path as working directory"})

--- Less vanilla

local diffdirs = require("diffdirs")
vim.keymap.set("n", "<leader>ll", diffdirs.pick, {desc="Diff file between 2 dirs"})
vim.api.nvim_create_user_command("DiffDirs", function(args) diffdirs.command(args) end, {
	nargs = "*",
	complete = "dir",
})

require("nd0.lsp")
require("nd0.plugins")

local qpack = require("qpack")
local got_plugins, pe = pcall(function() qpack:run() end)
if not got_plugins then
	vim.notify("Failed to get plugins", vim.log.levels.ERROR)
	print(pe)
end
pcall(vim.cmd.colorscheme, "catppuccin-macchiato") -- try plugin colorscheme

