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
	--	opts = {
	--		keywords = {
	--			FIX = { icon = ICONS.TOOL, color = "info" },
	--			TODO = { icon = "T", color = "warning" },
	--			HACK = { icon = ICONS.BIN, color = "warning" },
	--			WARN = { icon = ICONS.WARNING, color = "warning", alt = {"WARNING", "XXX"} },
	--			PERF = { icon = ICONS.GRAPH, alt = {"OPTIM", "PERFORMANCE", "OPTIMIZE"} },
	--			NOTE = { icon = ICONS.NOTE, color = "hint", alt = {"INFO"} },
	--			TEST = { icon = ICONS.TEST_BOX, color = "<leader>test",
	--				alt = { "TESTING", "PASSED", "FAILED" } },
	--		},
	--		colors = {
	--			error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
	--			warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
	--			info = { "DiagnosticInfo", "#2563EB" },
	--			hint = { "DiagnosticHint", "#10B981" },
	--			default = { "Identifier", "#7C3AED" },
	--			test = { "Identifier", "#FF00FF" },
	--		},
	--	},
	},
	-- {
	-- 	"nvim-telescope/telescope-fzf-native.nvim",
	-- 	-- To compile:
	-- 	-- build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
	-- 	-- To download bins
	-- 	-- branch = "feature/69-prebuilt-release-binaries",
	-- 	build = function()
	-- 		local jit_os = string.lower(jit.os)
	-- 		local jit_arch = string.lower(jit.arch)

	-- 		local pkg_os = "windows"
	-- 		local pkg_comp = "cc"
	-- 		if jit_os == "darwin" then
	-- 			pkg_os = "macos"
	-- 			pkg_comp = "gcc"
	-- 		elseif jit_os == "linux" then
	-- 			pkg_os = "ubuntu"
	-- 			pkg_comp = "gcc"
	-- 		end

	-- 		local pkg_arch = ""
	-- 		if jit_arch == "x64" or jit_arch == "x86" then
	-- 			pkg_arch = "x64" -- pray x64 machines can run x86 anyway
	-- 		elseif jit_arch == "arm" or jit_arch == "arm64" then
	-- 			pkg_arch = "arm" -- pray whatever arm machine works for it
	-- 		else
	-- 			-- for mips and whatever - screw that noone uses it
	-- 			-- I guess riscv stuff future but ¯\_(ツ)_/¯
	-- 			pkg_arch = "arm"
	-- 		end
	-- 		
	-- 		require('telescope-fzf-native').download_library({
	-- 			platform = pkg_os, -- "windows" | "ubuntu" | "macos"
	-- 			arch = pkg_arch, -- "x64" | "arm"
	-- 			compiler = pkg_comp, -- windows: "cc", unix: "gcc" | "clang"
	-- 			-- version = "0.0.2", -- release name found on GitHub release page, default: "dev"
	-- 		})
	-- 	end,
	-- },
	{
		"nvim-telescope/telescope.nvim", tag = "0.1.5",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local fzfn_ok, _ = pcall(require, "telescope-fzf-native")
			if fzfn_ok then
				require("telescope").load_extension("fzf")
			end

			local builtin = require("telescope.builtin")
			local actions = require("telescope.actions")

			require("telescope").setup({
				pickers = {
					find_files = { theme = "ivy" },
					git_files = { theme = "ivy" },
					git_status = { theme = "ivy" },
					live_grep = { theme = "ivy" },
					colorscheme = { theme = "dropdown" },
				},
				mappings = {
					-- i | n | v etc. for modes
					i = {
						-- Will is in horizontal scroll is in master branch wait for release
						-- ["<C-[>"] = actions.preview_scrolling_left,
						-- ["<C-]>"] = actions.preview_scrolling_right,
					},
				},
			})

			-- File Pickers
			vim.keymap.set("n", "<leader>tg", builtin.git_files,
				{desc = "Telescope git files"})
			vim.keymap.set("n", "<leader>tf", builtin.find_files,
				{desc = "Telescope find files"})
			vim.keymap.set("n", "<leader>tF", function()
				local ff_opts = { hidden = true }
				if vim.fn.executable("fd") == 1 then
					-- L = sym; H = hidden; I = ignored;
					ff_opts = { find_command = {"fd", "-HIL"} }
				elseif vim.fn.executable("rg") == 1 then
					ff_opts = { find_command = {"rg", "--files", "--hidden", "--follow"} }
				end
				builtin.find_files(ff_opts) end,
				{desc = "Telescope find files (hidden)"})
			vim.keymap.set("n", "<leader>th", builtin.help_tags,
				{desc = "Telescope help tags"})
			vim.keymap.set("n", "<leader>ts", function()
				builtin.grep_string({ search = vim.fn.input("Grep > ")})
			end, {desc = "Telescope grep string"})

			if vim.fn.executable("rg") == 1 then
				vim.keymap.set("n", "<leader>tr", function() builtin.live_grep({
						vimgrep_arguments = { "rg", "--vimgrep",
							"--follow",
					}}) end,
					{desc = "Telescope live grep"})
				vim.keymap.set("n", "<leader>tR", function() builtin.live_grep({
						vimgrep_arguments = { "rg", "--vimgrep",
							"--follow", "--unrestricted", "-uu", "--hidden",
					}}) end,
					{desc = "Telescope live grep (include all)"})
			else
				vim.keymap.set("n", "<leader>tr", function() print("!Missing: ripgrep") end,
					{desc = "Disabled: Telescope live grep"})
				vim.keymap.set("n", "<leader>tR", function() print("!Missing: ripgrep") end,
					{desc = "Disabled: Telescope live grep (all)"})
			end

			-- Vim Pickers
			vim.keymap.set("n", "<leader>tk", builtin.keymaps,
				{desc = "Telescope keymaps"})
			vim.keymap.set("n", "<leader>to", builtin.oldfiles,
				{desc = "Telescope oldfiles (recents)"})
			vim.keymap.set("n", "<leader>tS", builtin.spell_suggest,
				{desc = "Telescope spell suggest"})
			-- builtin.commands
			-- builtin.colorscheme (FULL)

			-- LSP Pickers
			vim.keymap.set("n", "<leader>tlr", builtin.lsp_references,
				{desc = "Telescope LSP references"})
			vim.keymap.set("n", "<leader>tlD", builtin.diagnostics,
				{desc = "Telescope LSP diagnostics"})
			vim.keymap.set("n", "<leader>tli", builtin.lsp_implementations,
				{desc = "Telescope LSP implementations"})
			vim.keymap.set("n", "<leader>tld", builtin.lsp_definitions,
				{desc = "Telescope LSP definitions"})
			vim.keymap.set("n", "<leader>tltd", builtin.lsp_type_definitions,
				{desc = "Telescope LSP type definition"})

			-- Git Pickers
			-- vim.keymap.set("n", "<leader>tvc", builtin.git_commits,
			-- 	{desc = "Telescope git commits"})
			vim.keymap.set("n", "<leader>tvb", builtin.git_branches,
				{desc = "Telescope git branches"})
			vim.keymap.set("n", "<leader>tvs", builtin.git_status,
				{desc = "Telescope git status"})
			vim.keymap.set("n", "<leader>tvS", builtin.git_stash,
				{desc = "Telescope git stash"})

			-- Treesitter Pickers
			vim.keymap.set("n", "<leader>tT", builtin.treesitter,
				{desc = "Telescope treesitter"})

			-- Extensions (seperate lazy entry)
		end,
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
		config = function()
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
	{
		"ThePrimeagen/harpoon",
		dependencies = { "nvim-lua/plenary.nvim" },
		branch = "harpoon2",
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup({
				settings = { 
					save_on_toggle = true,
					sync_on_close = true,
				}
			})

			-- do a QWERTY / DVORK switcher
			vim.keymap.set("n", "<leader>ha",
				function() harpoon:list():append() end,
				{desc = "Harpoon append list"})
			vim.keymap.set("n", "<C-e>",
				function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
				{desc = "Harpoon toggle quick menu"})
			vim.keymap.set("n", "<C-h>",
				function() harpoon:list():select(1) end,
				{desc = "Harpoon select 1"})
			vim.keymap.set("n", "<C-j>",
				function() harpoon:list():select(2) end,
				{desc = "Harpoon select 2"})
			vim.keymap.set("n", "<C-k>",
				function() harpoon:list():select(3) end,
				{desc = "Harpoon select 3"})
			vim.keymap.set("n", "<C-l>",
				function() harpoon:list():select(4) end,
				{desc = "Harpoon select 4"})
		end

	},
}
