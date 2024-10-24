local M = {}

M.check = function()
	vim.health.start("LSP Config Report")

	lang_checks = {
		"lua",
		"nix",
		"rust",
		"typescript",
	}
	for _, lang_check in ipairs(lang_checks) do
		local ok, lang_mod = pcall(require, "nd0.lite.lsp_configs."..lang_check)
		if ok then
			lang_mod.check()
		end
	end
end

return M
