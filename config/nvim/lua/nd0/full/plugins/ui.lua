local ok, lite_config = pcall(require, "nd0.lite.plugins.ui")


local config = {
	-- tokyonight
	{
		"folke/tokyonight.nvim",
		lazy = false,
		opts = { style = "night" }, -- storm | night | moon | day
		config = function()
		-- 	set_if_active("tokyonight")
		-- 	require("tokyonight").setup({
		-- 		-- @usage "storm" | "moon" | "night" | "day"
		-- 		style = "night",

		-- 		-- light for when vim.opt.background == light
		-- 		light_style = "storm",
		-- 		transparent = false,
		-- 		terminal_colors = true
		-- 	})
		end,
	},
	-- rosepine [x]
	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
			set_if_active("rose-pine")
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
if ok then
	for _, v in ipairs(lite_config) do
		table.insert(config, v)
	end
end
return config
