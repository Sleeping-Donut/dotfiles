local mode = string.lower(os.getenv('NVIM_CONFIG_MODE') or '')

if mode ~= 'full' and mode ~= 'lite' then
	mode = 'basic'
end

require("nd0." .. mode)

