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


local lazy_plugins = "lite.plugins"
local lazy_opts = {
	-- [Default Opts](https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration)
}

require("lazy").setup(lazy_plugins, lazy_opts)

