return {
	{
		"nvim-telescope/telescope.nvim", tag = "0.1.1",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-fzy-native.nvim",
		},
		config = function()
			require("telescope").load_extension("fzy_native")

			--local ok_wk, wk = pcall(require, "which-key") 
			--if ok_wk then
			--	wk.register({
			--		t = {
			--			f = {"<cmd>Telescope git_files<cr>", "Find Files (git)"},
			--			r = {"<cmd>Telescope live_grep<cr>", "ripgrep"},
			--			h = {"<cmd>Telescope help_tags<cr>", "Help"},
			--		},
			--	}, { prefix = "<leader>" })
			--end
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "tg", builtin.git_files, {desc = "Telescope git files"})
			vim.keymap.set("n", "tf", builtin.find_files, {desc = "Telescope grep files"})
			vim.keymap.set("n", "tr", builtin.live_grep, {desc = "Telescope live grep"})
			vim.keymap.set("n", "th", builtin.help_tags, {desc = "Telescope help tags"})
			vim.keymap.set("n", "ts", function()
				builtin.grep_string({ search = vim.fn.input("Grep > ")})
			end, {desc = "Telescope grep string"})
		end,
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
		config = function ()
			require("telescope").load_extension "file_browser"
			local fb_actions = require("telescope").extensions.file_browser.actions
			local ok_wk, wk = pcall(require, "which-key")
			if ok_wk then
				wk.register({
					["t,"] = { "<cmd>Telescope file_browser<cr>", "File Browser" },
					["t',"] = { "<cmd>Telescope fie_browser hidden=true<cr>", "File Browser (hidden)"},
					["t."] = { "<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>", "File Browser from current dir" },
					["t'."] = { "<cmd>Telescope file_browser path=%:p:h select_buffer=true hidden=true<cr>", "File Browser (hidden)"},
				}, {prefix="<leader>"})
			end
		end,
	},
	{
		"folke/which-key.nvim",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			require("which-key").setup({
			})
			local wk = require("which-key")
			wk.register({
				l = {"<cmd>Lazy<cr>", "Lazy"},
				y = {"'\"+y", "Copy to Clipboard"},
				s = {"w", "Save"},
			}, { prefix = "<leader>" })
		end,
	},
}
