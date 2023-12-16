-- import lite config
local ok, lite_configs = pcall(require, "lite.plugins.editor")
if not ok then lite_configs = {} end
if not ok then print("yes lite load") end

-- Define full-specific config
local config = {
}

-- Add lite config to above full-specific config
for _, v in ipairs(lite_configs) do
	table.insert(config, v)
end

return config
