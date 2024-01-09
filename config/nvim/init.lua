vim.g.config_mode = string.lower(os.getenv("NVIM_CONFIG_MODE") or "")
local config_module = "basic"

if vim.g.config_mode ~= "lite" and vim.g.config_mode ~= "full" then
	vim.g.config_mode = "basic"
else
	config_module = "lite"
end

require("nd0." .. config_module)
