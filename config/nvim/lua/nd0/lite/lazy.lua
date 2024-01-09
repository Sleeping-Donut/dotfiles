local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath
	})
end
vim.opt.runtimepath:prepend(lazypath)


local lazy_plugins = "nd0.lite.plugins"
local lazy_opts = {
	-- [Default Opts](https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration)
}

local disabled_plugins = {}
if vim.g.config_mode ~= "full" then
	disabled_plugins = {
		"rose-pine",
		"tokyonight",
		"lsp-zero",
	}
end

-- Change use of string for plugin module use table with spec
require("lazy").setup("nd0.lite.plugins", {
	install = {
		missing = true,
		colorscheme = { "desert", "habamax", "slate", },
	},
	disabled_plugins = disabled_plugins,
	ui = {
		icons = {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

