local M = {}

M.check = function()
	vim.health.start("LSP Config Report")

	local lang_checks = {
		"lua",
		"nix",
		"rust",
		"typescript",
	}
	for _, lang_check in ipairs(lang_checks) do
		local ok, lang_mod = pcall(require, "nd0.lite.lsp_configs."..lang_check)
		if lang_mod == "rust" then print("going to check rust") end
		if ok then
			if lang_mod == "rust" then print("checking rust") end
			lang_mod.check()
			if lang_mod == "rust" then print("checked rust") end
		end
	end
end

return M
