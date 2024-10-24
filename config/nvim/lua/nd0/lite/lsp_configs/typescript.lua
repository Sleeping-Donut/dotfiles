local M = {}

--- Check if Typescript config is ok
---@return boolean # Returns true if all dependencies are present as LSP can run
M.check = function()
	vim.health.start("LSP Config Report - Typescript")

	local dependencies = {
		"npm",
		"tsserver",
		"prettier"
	}

	local common = require("nd0.lite.lsp_configs.common")
	local all_ok = common.dependency_check("Typescript", dependencies)

	return all_ok
end

M.init = function()
	-- Don't know what if needed with nix also might need bun / deno handling
	if vim.fn.executable("npm") ~= 1 or vim.fn.executable("tsserver") ~= 1 then
		-- Log that it can't run
		-- print("you shouldn't be here returned ts")
		return
	end

	local common = require("nd0.lite.lsp_configs.common")
	local lspconfig = require("lspconfig")
	local ts_tools = require("typescript-tools")

	local tsserver_plugins = {} ---@type string[] The package name on npm

	-- TODO: Fix tsserver plugins, doesn't seem to be running at all
	if vim.fn.executable("prettier") == 1 then
		table.insert(tsserver_plugins, "prettier") -- add prettier plugin

		-- sort imports
		table.insert(tsserver_plugins, "@ianvs/prettier-plugin-sort-imports")

		if vim.fn.executable("prettier-plugin-tailwind") == 1 then
			-- add plugin to make prettier sort tailwind classes
			table.insert(tsserver_plugins, "prettier-plugin-tailwind")
		end
	end

	ts_tools.setup({
		on_attach = function(client, bufnr)
			common.on_attach(client, bufnr)
		end,
		root_dir = lspconfig.util.root_pattern('.editorconfig', 'package.json', '.git'),
		handlers = { -- to override some LSP methods
			["textDocument/formatting"] = function ()
				local current_file = vim.fn.expand("%")

				if vim.fn.executable("biome") == 1 then
					vim.api.nvim_command("silent !biome format --write " .. current_file)
				elseif vim.fn.executable("prettier") == 1 then
					vim.api.nvim_command("silent !prettier -w " .. current_file)
				end
			end,
		},
		settings = {
			tsserver_plugins = tsserver_plugins,
			-- might need to handle tsserver path
		},
	})

	-- eslint for linting etc
	if vim.fn.executable("vscode-eslint-language-server") == 1 then
		lspconfig.eslint.setup({
			-- packageManager = '"pnpm", ---@type "npm" | "yarn" | "pnpm"'
			on_attach = function(client, bufnr)
				common.on_attach(client, bufnr)
				-- Format on save
				-- vim.api.nvim_create_autocmd("BufWritePre", {
				-- 	buffer = bufnr,
				-- 	command = "EslintFixAll",
				-- })
			end,
		})
	end

	-- setup null-ls formatter maybe
end

return M
