vim.g.mapleader = " "
vim.keymap.set("n", "<Space>", "<Nop>", {desc = "Prevent moving cursor for <leader>"})

vim.opt.mouse = ""

local nmaps = vim.api.nvim_get_keymap("n")

-- Get explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, {desc = "Open Explorer"})

vim.keymap.set("n", "<leader>bw", function()
	vim.cmd("w")
	-- vim.api.nvim_echo({{":w"}}, false, {})
end, {desc = "Save"})

vim.keymap.set("n", "<C-u>", "<C-u>zz", {desc = "Jump up and center"})
vim.keymap.set("n", "<C-d>", "<C-d>zz", {desc = "Jump down and center"})

-- vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], {desc = "Copy to clipboard"})
vim.keymap.set("n", "<leader>Y", [["+Y]], {desc = "Copy to clipboard"})

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]], {desc = "Delete to black hole"})

vim.keymap.set("i", "<C-c>", "<Esc>", {desc = "C-c escapes when insert mode"})

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end, {desc = "Source current file"})
vim.keymap.set("n", "<leader>sc", function()
	vim.cmd("so "..vim.env.MYVIMRC)
	print("Config reloaded: "..vim.env.MYVIMRC)
end, {desc = "Source init.lua"})

vim.keymap.set("n", "<leader>ld", function()
	vim.cmd("lcd %:p:h")
	vim.cmd("pwd")
end, {desc = "Load current path as working directory"})
