local ICONS = {
	TOOLBOX = "🧰",
	ASTERISK = "✳️",
	INFO = "ℹ️" ,
	BIN = "🗑️",
	WARNING = "⚠️" ,
	GRAPH = "📊",
	NOTE = "🗈",
	TEST_TUBE = "🧪",

}
return {
	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require('treesitter-context').setup({})
		end
	},
	{
		"lvimuser/lsp-inlayhints.nvim",
		config = function()
			require('lsp-inlayhints').setup({})
			vim.cmd('hi! LspInlayHint guifg=#403d52 guibg=#1f1d2e')
		end
	},
	{
		'mhartington/formatter.nvim',
		config = function()
			require('formatter').setup({
				filetype = {
					rust = { require('formatter.filetypes.rust').rustfmt },
					typescript = { require('formatter.filetypes.typescript').prettier },
					typescriptreact = { require('formatter.filetypes.typescriptreact').prettier },
					lua = { require("formatter.filetypes.lua").luafmt }
				}
			})
	
			local ok_wk, wk = pcall(require, "which-key")
			if ok_wk then
				wk.register({
					F = {"<cmd>Format<cr>", "Format"}
				},{prefix="<leader>"})
			end
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			keywords = {
				FIX = { icon = ICONS.TOOLBOX, color = "info" },
				TODO = { icon = "T", color = "warning" },
				HACK = { icon = ICONS.BIN, color = "warning" },
				WARN = { icon = ICONS.WARNING, color = "warning", alt = {"WARNING", "XXX"} },
				PERF = { icon = ICONS.GRAPH, alt = {"OPTIM", "PERFORMANCE", "OPTIMIZE"} },
				NOTE = { icon = ICONS.NOTE, color = "hint", alt = {"INFO"} },
				TEST = { icon = ICONS.TEST_TUBE, color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
			},
			colors = {
				error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
				warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
				info = { "DiagnosticInfo", "#2563EB" },
				hint = { "DiagnosticHint", "#10B981" },
				default = { "Identifier", "#7C3AED" },
				test = { "Identifier", "#FF00FF" },
			},
		},
	},
}
