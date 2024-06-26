vim.opt.nu = true
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

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.showmode = false

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"
vim.opt.cursorline = true

vim.opt.encoding = "utf-8"
vim.scriptencoding = "utf-8"

vim.opt.list = true

local chars = {
	interpunct = "·",
	middle_ellipsis = "⋯",
	newline = "↵",
	right_arrow = "→",
	right_triangle = "▶",
	whitespace = "␣",
}
vim.opt.listchars = {
	conceal = chars.middle_ellipses,
	eol = chars.newline,
	nbsp = chars.interpunct,
	precedes = nil, lead = nil, trail = nil,
--	space = chars.interpunct,
	multispace = "   "..chars.right_triangle,
	tab = chars.right_arrow .. " ",
}

vim.opt.cmdheight = 1

