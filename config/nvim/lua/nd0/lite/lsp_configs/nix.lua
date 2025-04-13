local M = {}

--- Check if Nix config is ok
---@return boolean # Returns true if all dependencies are present as LSP can run
M.check = function()
	vim.health.start("LSP Config Report - Nix")

	local dependencies = {
		"nil"
	}

	local common = require("nd0.lite.lsp_configs.common")
	local all_ok = common.dependency_check("Nix", dependencies)

	return all_ok
end

M.init = function()
	-- check if lsp installed
	if vim.fn.executable("nil") ~= 1 then
		return
	end

	local common = require("nd0.lite.lsp_configs.common")
	local lspconfig = require("lspconfig")

	lspconfig.nil_ls.setup({
		capabilities = common.default_capabilities(),
		on_attach = common.on_attach,
		settings = {
			formatting = {
				command = { "nixfmt" };
			};
		};
	})
end

return M
