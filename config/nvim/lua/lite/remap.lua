vim.g.mapleader = " "
vim.keymap.set("n", "<Space>", "<Nop>", {desc = "Prevent moving cursor for <leader>"})

vim.opt.mouse = ""

local nmaps = vim.api.nvim_get_keymap("n")
--print(require("lite.utils").table_stringify(nmaps))

-- Get explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, {desc = "Open Explorer"})

vim.keymap.set("n", "<leader>bw", function()
	vim.cmd("w")
	print(":w")
end, {desc = "Save"})

-- vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set({"n", "v"}, "<leader>y", [["+y]]) -- WHAT DO?
vim.keymap.set("n", "<leader>Y", [["+Y]]) -- WHAT DO?

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
