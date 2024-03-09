--
-- Treesitter handles syntax highlighting and stuff
--
return {
	"nvim-treesitter/nvim-treesitter",
	version = false,
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		-- "nvim-treesitter/nvim-treesitter-textobjects",
		"nvim-treesitter/nvim-treesitter-context",
	},
	cmd = { "TSUpdateSync" },
	config = function ()
		local configs = require("nvim-treesitter.configs")
		local sitters = {}
		
		for _, v in ipairs({
			"lua", "vim", "vimdoc", "luadoc",
			"html", "javascript", "css",
			"json", "jsonc", "scss", "tsx", "vue", "svelte",
			-- Add in asciidoc once someone gets around to making the parser
			"markdown", "comment", -- "asciidoc",
			"python",
			"bash", "fish", -- "zsh", -- currently no zsh specific support
			"c", "cpp", "cmake",
			"zig",
			"rust",
			"java", "kotlin",
			"c_sharp",
			"nix",
			"ocaml",
			"elixir",
			"diff", "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore",
			"go",
			"dart",
			"matlab",
			"sql",
			"php",
			"terraform",
			"glsl", "cuda",
			"dockerfile",
			"yaml", "toml",
			"arduino",
			"latex", "bibtex",
		}) do
			table.insert(sitters, v)
		end

		-- These require tree-sitter cli to generate parsers
		if vim.fn.executable("tree-sitter") == 1 then
			local node_sitters = {
				"swift"
			}
			local c_sitters = {
				"astro"
			}

			if vim.fn.executable("node") == 1 then
				for _, v in ipairs(node_sitters) do
					table.insert(sitters, v)
				end
			else print("err: not all TS installed dep node not found") end
			if 1 <= vim.fn.executable("gcc") + vim.fn.executable("clang") then
				for _, v in ipairs(c_sitters) do
					table.insert(sitters, v)
				end
			else print("err: not all TS installed dep node not found") end
		end

		-- Register other filtypes to an existing parser
		require("nvim-treesitter.parsers").filetype_to_parsername.zsh = "bash"

		configs.setup({
			-- parser_install_dir =	-- look at example on git readme
			sync_install = false,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false
			},
			indent = { enable = true },
			ensure_installed = sitters,
		})
	end
}
