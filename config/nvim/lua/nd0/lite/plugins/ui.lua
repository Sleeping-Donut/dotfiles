local utils = require("utils")
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
				sections = {
					lualine_a = {
						{ 'mode', fmt = function(str)
							local split_str = utils.split(str, "-")
							local out_str = ""
							for _, word in ipairs(split_str) do
								if #out_str == 0 then
									out_str = word:sub(1,1)
								else
									out_str = out_str .. "-" .. word:sub(1,1)
								end
							end
							return out_str
						end }
					},
				}
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
	{
		"OlegGulevskyy/better-ts-errors.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		-- config = function()
		-- 	if (vim.fn.executable("prettier") == 1) then
		-- 		require("better-ts-errors").setup({
		-- 			keymap = "<leader>;p", -- Toggling keymap
		-- 		})
		-- 	end
		-- end,
		config = { keymaps = { toggle = "<leader>;p" } },
	},
}
