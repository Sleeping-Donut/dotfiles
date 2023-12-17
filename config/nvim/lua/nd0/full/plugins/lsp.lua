--
-- LSP (all the language completion, hints, etc.)
--

-- Migrate away from lsp-zero? Reference its README for how
if vim.fn.executable("nix --version") then
end
return {
		{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
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
		},
		config = function()
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
				print("we got lua")
				table.insert(lsps, "lua_ls")
			end
			if vim.fn.executable("node") == 1 then
				for _, v in ipairs({"hmtl", "cssls", "tsserver", "jsonls",
					"eslint", "astro", "tailwind", "svelte", "volar",
					-- "emmet-language-server",
					"sqlls", "vimls", "dockerls", "bashls", "ocamlls", "yamlls",
					"ansiblels",
				}) do
					table.insert(lsps, v)
				end
			end
			if vim.fn.executable("go") == 1 then
				table.insert(lsps, "gopls")
			end
			if vim.fn.executable("dotnet") == 1 then
				table.insert(lsps, "csharp_ls")
				table.insert(lsps, "fsautocomplete")
			end
			if vim.fn.executable("java") == 1 then
				table.insert(lsps, "java_language_server")
				table.insert(lsps, "kotlin_language_server")
			end
			if vim.fn.executable("gcc") == 1 or vim.fn.executable("clang") == 1 then
				table.insert(lsps, "clangd")
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

				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("i", "C-K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
				vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
				vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
				vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
				vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "<leader>f", function()
					vim.lsp.buf.format()
					print("Formatted")
				end, opts)
				vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
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

			lsp.configure("tailwindcss", {
				filetypes = { "rust", "tsx" },
			})

			lsp.setup()

			vim.diagnostic.config({ virtual_text = true })
		end,
	},
}
