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

require("nd0." .. config_module)
