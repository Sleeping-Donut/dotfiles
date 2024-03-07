local M = {}

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

return M
