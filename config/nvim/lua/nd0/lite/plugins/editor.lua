local ICONS = {
	TOOL = "⚒",
	ASTERISK = "*",
	INFO = "ⓘ",
	BIN = "🗑",
	WARNING = "⚠",
	GRAPH = "〽",
	NOTE = "🗈",
	TEST_BOX = "☐",
}
return {
	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require('treesitter-context').setup({})
		end
	},
	{
		"lvimuser/lsp-inlayhints.nvim",
		config = function()
			require('lsp-inlayhints').setup({})
			vim.cmd('hi! LspInlayHint guifg=#403d52 guibg=#1f1d2e')
		end
	},
	{
		'mhartington/formatter.nvim',
		config = function()
			require('formatter').setup({
				filetype = {
					rust = { require('formatter.filetypes.rust').rustfmt },
					typescript = { require('formatter.filetypes.typescript').prettier },
					typescriptreact = { require('formatter.filetypes.typescriptreact').prettier },
					lua = { require("formatter.filetypes.lua").luafmt }
				}
			})
	
			vim.keymap.set("n", "<leader>F", "<cmd>Format<cr>", {desc = "Format"})
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			keywords = {
				FIX = { icon = ICONS.TOOL, color = "info" },
				TODO = { icon = "T", color = "warning" },
				HACK = { icon = ICONS.BIN, color = "warning" },
				WARN = { icon = ICONS.WARNING, color = "warning", alt = {"WARNING", "XXX"} },
				PERF = { icon = ICONS.GRAPH, alt = {"OPTIM", "PERFORMANCE", "OPTIMIZE"} },
				NOTE = { icon = ICONS.NOTE, color = "hint", alt = {"INFO"} },
				TEST = { icon = ICONS.TEST_BOX, color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
			},
			colors = {
				error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
				warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
				info = { "DiagnosticInfo", "#2563EB" },
				hint = { "DiagnosticHint", "#10B981" },
				default = { "Identifier", "#7C3AED" },
				test = { "Identifier", "#FF00FF" },
			},
		},
	},
	{
		"nvim-telescope/telescope.nvim", tag = "0.1.5",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-fzy-native.nvim",
		},
		config = function()
			local builtin = require("telescope.builtin")
			-- File Pickers
			vim.keymap.set("n", "tg", builtin.git_files, {desc = "Telescope git files"})
			vim.keymap.set("n", "tf", builtin.find_files, {desc = "Telescope grep files"})
			vim.keymap.set("n", "th", builtin.help_tags, {desc = "Telescope help tags"})
			vim.keymap.set("n", "ts", function()
				builtin.grep_string({ search = vim.fn.input("Grep > ")})
			end, {desc = "Telescope grep string"})

			if vim.fn.executable("rg") == 1 then
				vim.keymap.set("n", "tr", builtin.live_grep, {desc = "Telescope live grep"})
			else
				vim.keymap.set("n", "tr", function() print("!Missing: ripgrep") end,
					{desc = "Disabled: Telescope live grep"})
			end

			if vim.fn.executable("fzy") == 1 then
				require("telescope").load_extension("fzy_native")
			end

			-- Vim Pickers
			-- builtin.keymaps
			-- builtin.oldfiles
			-- builtin.commands
			-- builtin.spell_suggest
			-- builtin.colorscheme (FULL)

			-- LSP Pickers
			-- builtin.lsp_references
			-- builtin.diagnostics
			-- builtin.lsp_implementations
			-- builtin.lsp_definitions
			-- builtin.lsp_type_definition

			-- Git Pickers
			-- builtin.git_commits
			-- builtin.git_branches
			-- builtin.git_status
			-- builtin.git_stash

			-- Treesitter Pickers
			-- builtin.treesitter

			-- Extensions (seperate lazy entry)
		end,
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
		config = function ()
			require("telescope").load_extension("file_browser")
			local fb_actions = require("telescope").extensions.file_browser.actions
			vim.keymap.set("n", "<leader>t,", "<cmd>Telescope file_browser<cr>",
				{desc = "File Browser"})
			vim.keymap.set("n", "<leader>t',", "<cmd>Telescope file_browser hidden=true<cr>",
				{desc = "File Browser (hidden)"})
			vim.keymap.set("n", "<leader>t.",
				"<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>",
				{desc = "File Browser from current dir"})
			vim.keymap.set("n", "<leader>t.",
				"<cmd>Telescope file_browser hidden=true path=%:p:h select_buffer=true<cr>",
				{desc = "File Browser (hidden) from current dir"})
		end,
	},
	-- {
	-- 	"folke/which-key.nvim",
	-- 	config = function()
	-- 		vim.o.timeout = true
	-- 		vim.o.timeoutlen = 300
	-- 		require("which-key").setup({
	-- 		})
	-- 		local wk = require("which-key")
	-- 		wk.register({
	-- 			l = {"<cmd>Lazy<cr>", "Lazy"},
	-- 			y = {"'\"+y", "Copy to Clipboard"},
	-- 			s = {"w", "Save"},
	-- 		}, { prefix = "<leader>" })
	-- 	end,
	-- },
}
