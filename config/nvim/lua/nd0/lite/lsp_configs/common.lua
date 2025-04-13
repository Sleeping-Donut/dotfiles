-- Common Configurations for LSPs

local M = {}

--- Check if the dependencies for a specific language are available.
---@param language string # The programming language
---@param dependencies string[] # Array of dependency names as strings
---@param light_dependencies string[]? # Array of light  dependency names as strings
---@return boolean # Returns true if all dependencies are found, otherwise false
M.dependency_check = function(language, dependencies, light_dependencies)
	local ok = true
	-- Required dependencies
	for _, dependency in ipairs(dependencies) do
		if vim.fn.executable(dependency) == 1 then
			vim.health.ok(language.." dependency found: "..dependency)
		else
			vim.health.error(language.." dependency not found:"..dependency)
			ok = false
		end
	end

	-- Extra dependencies
	for _, dependency in ipairs(light_dependencies or {}) do
		if vim.fn.executable(dependency) == 1 then
			vim.health.ok(language .. " dependency found: " .. dependency)
		else
			vim.health.warn(language .. " dependency not found:" .. dependency)
		end
	end
	return ok
end

--- Function to run when any LSP attaches to a buffer.
---@param client vim.lsp.Client # The LSP client that attached
---@param bufnr integer # The buffer number for the attached buffer
M.on_attach = function(client, bufnr)

	-- Nice defaults for keymaps
	local function opt_d(description)
		return {
			buffer = bufnr, remap = false, desc = description,
		}
	end

	vim.keymap.set("n", "K", vim.lsp.buf.hover, opt_d("LSP hover prompt"))
	vim.keymap.set("i", "<C-K>", vim.lsp.buf.hover, opt_d("LSP hover prompt (insert)"))
	vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opt_d("LSP definition"))
	vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opt_d("LSP declaration"))
	vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opt_d("LSP implementation"))
	vim.keymap.set("n", "<leader>go", vim.lsp.buf.type_definition, opt_d("LSP type definition"))
	vim.keymap.set("n", "<leader>gs", vim.lsp.buf.signature_help, opt_d("LSP signature help"))
	vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opt_d("LSP signature help"))
	vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opt_d("LSP references"))
	vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opt_d("LSP references"))
	vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opt_d("LSP workspace symbol"))
	vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opt_d("LSP code action"))
	vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opt_d("LSP rename"))
	if client.server_capabilities.inlayHintProvider then
		vim.keymap.set("n", "<leader>h", function()
			local enabled_now = vim.lsp.inlay_hint.is_enabled()
			vim.lsp.inlay_hint.enable(not enabled_now)
			if not enabled_now then
				print("Inlay Hints: On")
			else
				print("Inlay Hints: Off")
			end
		end, opt_d("LSP toggle inlay hints"))
	end
	if client.supports_method("textDocument/formatting") then
		local format = function()
			vim.lsp.buf.format({ async = true, bufnr = bufnr })
			print("Formatted")
		end
		vim.keymap.set("n", "<leader>f", format, opt_d("LSP format"))
	end

end

M.default_capabilities = function()
	return require("cmp_nvim_lsp").default_capabilities()
end

return M

