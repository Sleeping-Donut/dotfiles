--- @alias DepSpec string | vim.pack.Spec
--- @alias PackSpec string

--- QPack module
--- @class QPackBatcher
--- @field _deps DepSpec[]	List of pack Specs to install
--- @field _loadpack PackSpec[] List of packs to load
--- @field _configs (fun())[] List of zero-argument setup functions
local M = {
	_deps = {},
	_loadpack = {},
	_configs = {},
}

--- Loads a built-in pack plugin via :packadd
--- @param name string  The pack plugin name
--- @param config? fun() Function to run after packadd
function M:load(name, config)
	if name then
		table.insert(self._loadpack, name)
	end
	if config then
		table.insert(self._configs, config)
	end
end

--- Adds a plugin to the batch
--- @param deps? DepSpec | DepSpec[]: URL string or list of plugin tables
--- @param config? function: Function to run after plugins are added
function M:add(deps, config)
	local normalized = {}
	if deps == nil then
	elseif type(deps) == "string" then
		normalized = { deps }
	elseif type(deps) == "table" then
		---@diagnostic disable-next-line: deprecated
		local isList = vim.islist and vim.islist(deps) or vim.tbl_islist(deps)
		if isList then
			normalized = deps -- It is an array of Specs
		else
			normalized = { deps } -- It is a single Spec
		end
	end

	-- Append deps to master list
	for _, s in ipairs(normalized) do
		table.insert(self._deps, s)
	end

	-- Append config to master list
	if config then
		table.insert(self._configs, config)
	end
end

--- Executes the batch install and runs configs
function M:run()
	for _, name in ipairs(self._loadpack) do
		vim.cmd.packadd(name)
	end
	self._loadpack = {}

	if #self._deps > 0 then
		-- 1. Batch add to runtimepath and trigger installs
		vim.pack.add(self._deps)
		self._deps = {}
	end

	-- 2. Run all setup functions
	for _, config in ipairs(self._configs) do
		config()
	end
	self._configs = {}
end

return M

