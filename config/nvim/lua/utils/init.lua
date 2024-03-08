local M = {}

--- Split string by delimiter
-- use provided delimiter to split a string into a list
-- @param instr The input string to be split.
-- @param sep The delimiter to be used. Default: "%s"
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
-- @param cmd The command to be executed
M.cmd_status = function(cmd)
	if cmd == nil then
		cmd = ""
	end
	vim.fn.system(cmd)
	return vim.v.shell_error
end

--- Shallow merge to tables
-- write key-value pairs from tbl into src_tbl
-- @param src_tbl The table that values will be merged into.
-- @param tbl The table that will have it's values copied.
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

return M
