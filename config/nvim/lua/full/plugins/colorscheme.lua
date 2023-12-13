return {
	-- tokyonight
	{
		"folke/tokyonight.nvim",
		--lazy = true,
		opts = { style = "moon" } -- storm | night | moon | day
	},
	-- rosepine [x]
	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
			vim.cmd("colorscheme rose-pine")
		end
	},
}
