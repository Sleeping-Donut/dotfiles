local M = {}

--- Stringify Table
--- return table as string of all key value pairs
---@param tbl table # The table that will be turned into a string
M.table_stringify = function(tbl)
	if type(tbl) == 'table' then
		local s = '{ '
		for k,v in pairs(tbl) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. M.table_stringify(v) .. ','
		end
		return s .. '} '
	else
		return tostring(tbl)
	end
end

--- Split string by delimiter use provided delimiter to split a string
--- into a list
---@param instr string # The input string to be split.
---@param sep string # The delimiter to be used. Default: "%s"
M.split = function(instr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(instr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

--- Run command in shell and return execution status code
-- passed command is run in the shell and the error code is returned
---@param cmd string # The command to be executed
M.cmd_status = function(cmd)
	if cmd == nil then
		cmd = ""
	end
	vim.fn.system(cmd)
	return vim.v.shell_error
end

--- Shallow merge to tables
-- write key-value pairs from tbl into src_tbl
---@param src_tbl table The table that values will be merged into.
---@param tbl table The table that will have it's values copied.
M.tbl_merge = function(src_tbl, tbl)
	if src_tbl == nil then
		src_tbl = {}
	end
	if tbl == nil then
		tbl = {}
	end
	for k, v in pairs(tbl) do
		src_tbl[k] = v
	end
end

--- Checks if any LSP client is attached to the current buffer.
---@return boolean # Returns true if at least one LSP client is attached to the current buffer, false otherwise.
M.is_lsp_attached = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_active_clients({ bufnr = bufnr })

	-- Check if there are any clients attached to the current buffer
	for _, client in ipairs(clients) do
		if client.attached_buffers[bufnr] then
			return true
		end
	end

	return false
end

return M
