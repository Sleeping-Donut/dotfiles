vim.g.active_colorscheme = "desert"
-- vim.g.active_colorscheme = "habamax"
vim.opt.background = "dark"

return {
	"nvim-tree/nvim-web-devicons",
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options= {
					theme = "codedark",
					section_separators = { left = "", right = "" },
					component_separators = { left = "", right = "|" },
				},
			})
		end,
	},
	{ "j-hui/fidget.nvim" },
}

