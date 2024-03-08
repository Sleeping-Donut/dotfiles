--
-- LSP (all the language completion, hints, etc.)
--

-- [Migrate away from lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/you-might-not-need-lsp-zero.md)
if vim.fn.executable("nix") then
end
local utils = require("utils")
return {
		{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
		enabled = vim.g.is_full_config,
		dependencies = {
			-- LSP Support
			{"neovim/nvim-lspconfig"},				-- Required
			{										-- Optional
				"williamboman/mason.nvim",
				build = function()
					pcall(vim.cmd, "MasonUpdate")
				end,
				config = {
					ui = {
						border = "rounded",
					},
				},
			},
			{"williamboman/mason-lspconfig.nvim"}, -- Optional

			-- Autocompletion
			{"hrsh7th/nvim-cmp"},     -- Required
			{"hrsh7th/cmp-nvim-lsp"}, -- Required
			{"hrsh7th/cmp-buffer"},
			{"hrsh7th/cmp-path"},
			{"hrsh7th/cmp-nvim-lua"},
			{"saadparwaiz1/cmp_luasnip"},

			-- Snippets
			{"L3MON4D3/LuaSnip"},     -- Required
			{"rafamadriz/friendly-snippets"},
			{ "j-hui/fidget.nvim", tag = "v1.2.0", },
		},
		config = function()
			require("fidget").setup()
			-- This config can be moved into own file to seperate from lazy
			local lsp = require("lsp-zero")

			lsp.preset("recommended")

			-- [LSP servers and configs](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)
			local lsps = {}
			if vim.fn.executable("rustc") == 1 then
				for _, v in ipairs({"rust_analyzer", "rnix",
					-- "asm_lsp" -- dependent on some ssl dir check it out
				}) do
					table.insert(lsps, v)
				end
			end
			if vim.fn.executable("python") == 1 or vim.fn.executable("python3") == 1
				or vim.fn.executable("py") == 1 or vim.fn.executable("py3") == 1 then
				table.insert(lsps, "pylsp")
			end
			if vim.fn.executable("lua-language-server") == 1 then
				table.insert(lsps, "lua_ls")
			end
			if vim.fn.executable("node") == 1 then
				for _, v in ipairs({"html", "cssls", "tsserver", "jsonls",
					"eslint", "astro", "tailwindcss", "svelte", "volar",
					-- "emmet-language-server",
					"sqlls", "vimls", "dockerls", "bashls", "yamlls",
					"ansiblels",
				}) do
					table.insert(lsps, v)
				end
			end
			if vim.fn.executable("opam") == 1 then
				table.insert(lsps, "ocamllsp")
			end
			if vim.fn.executable("go") == 1 then
				table.insert(lsps, "gopls")
			end
			if vim.fn.executable("dotnet") == 1 then
				table.insert(lsps, "csharp_ls")
				table.insert(lsps, "fsautocomplete")
			end
			if vim.fn.executable("gcc") == 1 or vim.fn.executable("clang") == 1 then
				table.insert(lsps, "clangd")
			end
			if utils.cmd_status("java --version") == 0 then
				table.insert(lsps, "java_language_server")
				table.insert(lsps, "kotlin_language_server")
			end
			lsp.ensure_installed(lsps)
				-- "docker_compose_language_service",
				-- "ansiblels",
				-- "arduino_language_server",
				-- "graphql",

				--"elixrls",
				--"matlab_ls",
			--})

			-- To have global vim namespace work
			--lsp.nvim_workspace()-- replace with nvm_lua_ls()
			local ok_lspc, lsp_config = pcall(require, "lspconfig")
			if ok_lspc and vim.fn.executable("lua-language-server") == 1 then
				lsp_config.lua_ls.setup(lsp.nvim_lua_ls())
			end

			lsp.set_preferences({
				suggest_lsp_servers = false,
				sign_icons = {
					error = "E",
					warn = "W",
					hint = "H",
					info = "I",
				},
			})

			lsp.on_attach(function(client, bufnr)
				local opts = {buffer = bufnr, remap = false}
				-- opt extend
				local opt_e = function(tbl) return utils.tbl_merge(opts, tbl) end

				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opt_e({desc = "LSP definition"}))
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opt_e({desc = "LSP hover prompt"}))
				vim.keymap.set("i", "C-K", vim.lsp.buf.hover, opt_e({desc = "LSP hover prompt (insert)"}))
				vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opt_e({desc = "LSP workspace symbol"}))
				vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opt_e({desc = "LSP float diagnostic"}))
				vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opt_e({desc = "LSP goto next"}))
				vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opt_e({desc = "LSP goto prev"}))
				vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opt_e({desc = "LSP code action"}))
				vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opt_e({desc = "LSP references"}))
				vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opt_e({desc = "LSP rename"}))
				vim.keymap.set("n", "<leader>f", function()
					vim.lsp.buf.format()
					print("Formatted")
				end, opt_e({desc = "LSP format"}))
				vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opt_e({desc = "LSP signature help"}))
			end)

			local ok_cmp, cmp = pcall(require, "cmp")
			if ok_cmp then
				local cmp_select = {behavior = cmp.SelectBehavior.Select}
				local cmp_mappings = lsp.defaults.cmp_mappings({
					["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
					["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete(),
				})

				cmp_mappings["<Tab>"] = nil
				cmp_mappings["<S-Tab>"] = nil

				lsp.setup_nvim_cmp({
				  mapping = cmp_mappings
				})
			end

			if vim.fn.executable("tailwind-language-server") == 1 then
				lsp.configure("tailwindcss", {
					filetypes = { "rust", "tsx" },
				})
			end

			lsp.setup()

			vim.diagnostic.config({ virtual_text = true })
		end,
	},
}
