---Default keymap hints
---@type { lhs: string, desc: string, help: string }[]
local M = {
	{ lhs = "<C-S>",        desc = "Signature help (insert)",   help = "i_CTRL-S" },
	{ lhs = "<C-W>d",       desc = "Diagnostic float",          help = "CTRL-W_d" },
	{ lhs = "<leader>f",    desc = "Format buffer",             help = "lsp" },
	{ lhs = "<leader>gD",   desc = "Go to declaration",         help = "lsp" },
	{ lhs = "<leader>gd",   desc = "Go to definition",          help = "lsp" },
	{ lhs = "K",            desc = "Hover documentation",       help = "K" },
	{ lhs = "[D",           desc = "First diagnostic",          help = "[D" },
	{ lhs = "[d",           desc = "Previous diagnostic",       help = "[d" },
	{ lhs = "[s",           desc = "Previous misspelling",      help = "[s" },
	{ lhs = "]D",           desc = "Last diagnostic",           help = "]D" },
	{ lhs = "]d",           desc = "Next diagnostic",           help = "]d" },
	{ lhs = "]s",           desc = "Next misspelling",          help = "]s" },
	{ lhs = "gO",           desc = "Document symbols",          help = "gO" },
	{ lhs = "gcc",          desc = "Comment",                   help = "gri" },
	{ lhs = "gra",          desc = "Code action",               help = "gra" },
	{ lhs = "gri",          desc = "Implementation",            help = "gri" },
	{ lhs = "grn",          desc = "Rename symbol",             help = "grn" },
	{ lhs = "grr",          desc = "References",                help = "grr" },
	{ lhs = "grt",          desc = "Type definition",           help = "grt" },
	{ lhs = "z=",           desc = "Spell suggest",             help = "z=" },
}

return M
