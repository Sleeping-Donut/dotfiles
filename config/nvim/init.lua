vim.g.config_mode = string.lower(os.getenv("NVIM_CONFIG_MODE") or "")
local config_module = "basic"
vim.g.is_full_config = false

if vim.g.config_mode == "lite" or vim.g.config_mode == "full" then
	config_module = "lite"
else
	vim.g.config_mode = "basic"
end

if vim.g.config_mode == "full" then
	vim.g.is_full_config = true
end

local ok, _ = pcall(require, "nd0." .. config_module)
if not ok then
	-- fallback to basic config
	pcall(require, "nd0.basic")
	vim.api.nvim_echo({{"error: could not load config " .. config_module .. " using fallback"}}, false, {})
end
-- require("nd0." .. config_module)
