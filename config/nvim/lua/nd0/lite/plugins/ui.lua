return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "auto",
					section_separators = { left = "", right = "" },
					component_separators = { left = "", right = "|" },
				},
			})
		end,
	},
	{
		"ellisonleao/gruvbox.nvim",
		lazy = true,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
	},
	{
		"folke/tokyonight.nvim",
		lazy = true,
		opts = { style = "night" }, -- storm | night | moon | day
		config = function()
		-- 	set_if_active("tokyonight")
		require("tokyonight").setup({
			-- @usage "storm" | "moon" | "night" | "day"
			-- style = "night",

			-- light for when vim.opt.background == light
			light_style = "storm",
			transparent = false,
			terminal_colors = true
		})
		end,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = true,
		config = function()
			-- set_if_active("rose-pine")
			require("rose-pine").setup({
				-- variant respects vim.o.background: dawn when light & dark_variant when dark
				-- @usage "auto" | "main" | "moon" | "dawn"
				variant = "auto",

				-- @usage "main" | "moon" | "dawn"
				dark_variant = "main",
			})
		end
	},
}
