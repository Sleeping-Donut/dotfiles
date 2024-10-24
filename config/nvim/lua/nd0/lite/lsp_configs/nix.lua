local M = {}

M.check = function()
	vim.health.start("LSP Config Report - Nix")
end

M.init = function()
	if vim.fn.executable("nil") ~= 1 then
		return
	end

	local common = require("nd0.lite.lsp_confgs.common")
	local lspconfig = require("lspconfig")

	lspconfig.nil_ls.setup({
		capabilities = common.default_capabilities(),
		on_attach = common.on_attach,
	})
end

return M
