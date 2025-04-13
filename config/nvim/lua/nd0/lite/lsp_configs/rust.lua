local M = {}

M.check = function()
	vim.health.start("LSP Config Report - Rust")

	local dependencies = {
		"rust-analyzer",
	}
	local light_dependencies = {
		"rustc",
		"rustfmt",
		"rustgdb",
		"rustlldb",
	}
	local common = require("nd0.lite.lsp_configs.common")
	local all_ok = common.dependency_check("Rust", dependencies, light_dependencies)

	return all_ok
end

M.init = function()
	if vim.fn.executable("rust-analyzer") ~= 1 then
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

	--#region Keymaps that maybe should be in after/ftplugin
	local bufnr = vim.api.nvim_get_current_buf()
	vim.keymap.set("n", "vrn", function()
		vim.cmd.RustLsp("codeAction") -- supports rust-analyzer's grouping
		-- or vim.lsp.buf.codeAction() if you don't want grouping.
	end, { silent = true, buffer = bufnr })
	vim.keymap.set("n", "K", function()
		vim.cmd.RustLsp({"hover", "actions"})
	end, { silent = true, buffer = bufnr })
	vim.keymap.set("i", "<C-K>", function()
		vim.cmd.RustLsp({"hover", "actions"})
	end, { silent = true, buffer = bufnr })
	--#endregion
end

return M
