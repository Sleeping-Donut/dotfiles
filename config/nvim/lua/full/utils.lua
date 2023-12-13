local M = {}

function M.table_stringify(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. M.table_stringify(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function M.register_keymaps(mappings, opts)
	local ok,wk = pcall(require, "which-key")
	if ok then
		wk.register(mappings, opts)
	else
		if opts == nil or type(opts) ~= table then
			opts = {}
		end
		local a_opts = {
			-- reference which-key README for defaults
			mode = opts.mode or "n",
			prefix = opts.prefix or "",
			buffer = opts.buffer or nil,
			silent = true,
			noremap = true,
			nowait = false,
			expr = false,
		}
		print("NOT IMPLEMENTED REGISTER KEY FALLBACK")
	end
end

return M
