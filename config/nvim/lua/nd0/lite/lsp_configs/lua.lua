local M = {}

--- Check if Lua config is ok
---@return boolean # Returns true if all dependencies are present as LSP can run
M.check = function()
	vim.health.start("LSP Config Report - Lua")

	local dependencies = {
		"lua-language-server"
	}

	local common = require("nd0.lite.lsp_configs.common")
	local all_ok = common.dependency_check("Lua", dependencies)

	return all_ok
end

M.init = function()
	-- check if lsp installed
	if vim.fn.executable("lua-language-server") ~= 1 then
		return
	end

	local common = require("nd0.lite.lsp_configs.common")
	local lspconfig = require("lspconfig")

	lspconfig.lua_ls.setup({
		capabilities = common.default_capabilities(),
		on_attach = common.on_attach,
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
				},
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = {
						vim.env.VIMRUNTIME,
					},
				},
			},
		},
	})
end

return M

