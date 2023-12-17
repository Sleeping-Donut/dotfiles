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
		
		for _, v in ipairs({"lua", "vim", "vimdoc", "luadoc",
			"html", "javascript", "css",
			"json", "jsonc", "scss", "tsx", "astro", "vue", "svelte",
			"markdown", "comment",
			"python",
			"bash", "fish",
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
		if vim.fn.executable("node") == 1 then
			for _, v in ipairs({"swift"}) do
				table.insert(sitters, v)
			end
		end
			
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
