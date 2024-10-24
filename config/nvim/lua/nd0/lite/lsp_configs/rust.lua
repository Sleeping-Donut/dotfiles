local M = {}

M.check = function()
	vim.health.start("LSP Config Report - Rust")
end

M.init = function()
	if vim.fn.executable("rust-analyzer") ~= 1 then
		-- Log that it failed
		return
	end

	local common = require("nd0.lite.lsp_configs.common")

	-- Maybe setup codelldb for better debugging (nix: vscode-extensions.vadimcn.vscode-lldb.adapter)

	vim.g.rustaceanvim = {
		server = {
			on_attach = function(client, bufnr)
				common.on_attach(client, bufnr)
			end
		}
	}

	--	local bufnr = vim.api.nvim_get_current_buf()
	--	vim.keymap.set("n", "vrn", function()
	--		vim.cmd.RustLsp('codeAction') -- supports rust-analyzer's grouping
	--		-- or vim.lsp.buf.codeAction() if you don't want grouping.
	--	end, { silent = true, buffer = bufnr })
end

return M
