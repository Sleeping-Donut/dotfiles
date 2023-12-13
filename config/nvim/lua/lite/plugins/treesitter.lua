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
		configs.setup({
			-- parser_install_dir =	-- look at example on git readme
			sync_install = false,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false
			},
			indent = { enable = true },
			ensure_installed = {
				----------------------------------------------
				-- If get error from one of these (especially
				-- from cc1plus) try install g++ because it
				-- could be from c++ compile failing bad
				----------------------------------------------
				"lua", "vim", "vimdoc",
				"html", "javascript", "css", "typescript", "json", "jsonc", "scss",
				"tsx", "astro", "vue",
				"c", "cmake", "cpp", "svelte",
				"c_sharp",
				"rust",
				"comment",
				"markdown",
				"python",
				"java", "kotlin",
				"bash", "fish",
				"zig",
				"elixir",
				"diff", "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore",
				"dart",
				"lua", "luadoc",
				"nix",
				"matlab",
				"ocaml",
				"php",
				"sql",
				"swift",
				"terraform",
				"vim",
				"go",
				"glsl", "cuda",
				"dockerfile",
				"yaml", "toml",
				"arduino",
				"latex", "bibtex",
			},
		})
	end
}
