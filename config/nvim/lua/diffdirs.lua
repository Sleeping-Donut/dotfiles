local M = {
	dir_a = nil,
	dir_b = nil,
}

local diffdirs_group = vim.api.nvim_create_augroup("DiffDirs", { clear = true })

local function normalize(path)
	if path == nil or path == "" then return nil end
	return vim.fn.fnamemodify(path, ":p"):gsub("/+$", "")
end

local function relative_files(dir)
	return vim.fn.systemlist({
		"fd", "--type", "f", "--no-ignore-vcs",
		"--base-directory", dir, "."
	})
end

local function open_diff(relpath, orig_win)
	local a = M.dir_a .. "/" .. relpath
	local b = M.dir_b .. "/" .. relpath

	if vim.api.nvim_win_is_valid(orig_win) then
		vim.api.nvim_set_current_win(orig_win)
	end

	vim.cmd("botright new " .. vim.fn.fnameescape(a))
	local win_a = vim.api.nvim_get_current_win()

	vim.cmd("rightbelow vertical diffsplit " .. vim.fn.fnameescape(b))
	local win_b = vim.api.nvim_get_current_win()

	vim.schedule(function()
		if vim.api.nvim_win_is_valid(win_a) then
			vim.api.nvim_set_current_win(win_a)
		end
	end)

	local function close_both()
		pcall(vim.api.nvim_win_close, win_a, true)
		pcall(vim.api.nvim_win_close, win_b, true)
	end
	vim.api.nvim_create_autocmd("WinClosed", {
		group = diffdirs_group,
		pattern = tostring(win_a),
		once = true,
		callback = close_both,
	})
	vim.api.nvim_create_autocmd("WinClosed", {
		group = diffdirs_group,
		pattern = tostring(win_b),
		once = true,
		callback = close_both,
	})
end

function M.pick()
	if not M.dir_a or not M.dir_b then
		print("DiffDirs: set both dirs first")
		return
	end

	local orig_win = vim.api.nvim_get_current_win()

	MiniPick.start({
		source = {
			name = string.format(
				"Diff (%s ↔ %s)",
				vim.fn.fnamemodify(M.dir_a, ":t"),
				vim.fn.fnamemodify(M.dir_b, ":t")
			),
			items = relative_files(M.dir_a),
			choose = function(relpath)
				open_diff(relpath, orig_win)
			end,
		}
	})
end

function M.setup(opts)
	M.dir_a = normalize(opts.dir_a)
	M.dir_b = normalize(opts.dir_b)
end

function M.command(args)
	local sub = (args.args or ""):match("%S+")
	local rest = (args.args or ""):match("%S+%s+(.*)") or ""

	if sub == nil or sub == "" or sub == "pick" then
		M.pick()
	elseif sub == "set-a" then
		M.dir_a = normalize(rest:match("%S+") or "")
		print("dir_a = " .. M.dir_a)
	elseif sub == "set-b" then
		M.dir_b = normalize(rest:match("%S+") or "")
		print("dir_b = " .. M.dir_b)
	elseif sub == "status" then
		print(string.format("dir_a: %s\ndir_b: %s", M.dir_a or "<unset>", M.dir_b or "<unset>"))
	elseif rest ~= "" then
		local a, b = normalize(sub), normalize(rest:match("%S+"))
		if a and b then
			M.dir_a, M.dir_b = a, b
			M.pick()
		end
	end
end

return M
