local lsp_group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP Actions",
	group = lsp_group,
	callback = function(ev)
		local bufnr = ev.buf
		local client_id = ev.data.client_id
		local client = vim.lsp.get_client_by_id(client_id)
		if not client then return end

		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client_id, bufnr, { autotrigger = false })
		end
		if client:supports_method("textDocument/hover") then
			vim.keymap.set("n", "K", function()
				vim.lsp.buf.hover({
					border = "solid",
				})
			end, {
				buffer = bufnr,
				desc = "LSP hover"
			})
		end
		if client:supports_method("textDocument/inlayHint") then
			local default_inlay = false
			vim.lsp.inlay_hint.enable(default_inlay, { bufnr = bufnr })
		end
		if client:supports_method("textDocument/formatting") then
			-- default gq format might timeout? - check
			vim.keymap.set("n", "<leader>f", function()
				vim.lsp.buf.format({
					bufnr = bufnr,
					id = client_id,
					timeout_ms = 1000 * 3
				})
			end, { buffer = bufnr, desc = "Format" })
		end
	end,
})

vim.keymap.set("n", "<leader>th", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }))
end, { desc = "Toggle Inlay Hints" })

local function ts_info()
	local ft = vim.bo.filetype
	if ft == "" then
		vim.notify("No filetype detected", vim.log.levels.WARN)
		return
	end

	local has_parser, parser = pcall(vim.treesitter.get_parser)
	local has_highlights = pcall(vim.treesitter.query.get_files, ft, "highlights")

	local lines = {
		"# Treesitter Status",
		"",
		"Filetype: "..ft,
		"Parser loaded: "..(has_parser and "☑" or "☒"),
		"Language: "..(has_parser and parser:lang() or ft),
		"Highlights: "..(has_highlights and "☑" or "☒"),
	}

	-- List installed parsers
	local installed = {}
	for _, rtp in ipairs(vim.api.nvim_list_runtime_paths()) do
		local dir = rtp .. "/parser"
		if vim.fn.isdirectory(dir) == 1 then
			for _, f in ipairs(vim.fn.readdir(dir)) do
				local name = f:match("(.*)%.so$") or f:match("(.*)%.dylib$")
				if name then installed[name] = true end
			end
		end
	end
	local names = vim.tbl_keys(installed)
	if #names > 0 then
		table.sort(names)
		table.insert(lines, "")
		table.insert(lines, "Installed parsers ("..#names.."):")
		for _, lang in ipairs(names) do
			table.insert(lines, "  • "..lang)
		end
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf,  0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = math.min(50, vim.o.columns - 4),
		height = #lines + 2,
		col = math.max(0, (vim.o.columns - 50) / 2),
		row = math.max(0, (vim.o.lines - #lines -2) / 2),
		border = "single",
		style = "minimal",
		title = "TSInfo",
		title_pos = "center",
	})
end
vim.api.nvim_create_user_command("TsInfo", ts_info, {})

local function lsp_info()
	local clients = vim.lsp.get_clients()
	if #clients == 0 then
		vim.notify("No active LSP clients", vim.log.levels.WARN)
		return
	end
	local lines = { "# Active LSP Clients" }
	for _, client in ipairs(clients) do
		table.insert(lines, "")
		table.insert(lines, "• " .. client.name .. " (id " .. client.id .. ")")
		local bufs = {}
		for buf, _ in pairs(client.attached_buffers or {}) do
			local name = vim.api.nvim_buf_get_name(buf)
			if name ~= "" then
				table.insert(bufs, vim.fn.fnamemodify(name, ":~:."))
			end
		end
		if #bufs > 0 then
			table.insert(lines, "	Attached to: " .. table.concat(bufs, ", "))
		else
			table.insert(lines, "	(not attached to any buffer)")
		end
		local cmds = client.commands or {}
		if #cmds > 0 then
			table.insert(lines, "	Commands: " .. table.concat(cmds, ", "))
		end
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = math.min(80, vim.o.columns - 4),
		height = #lines + 2,
		col = math.max(0, (vim.o.columns - 80) / 2),
		row = math.max(0, (vim.o.lines - #lines - 2) / 2),
		border = "rounded",
		style = "minimal",
		title = " LspInfo ",
		title_pos = "center",
	})
	vim.wo[win].wrap = false
end
vim.keymap.set("n", "<leader>li", lsp_info,    { desc = "LSP Info" })
vim.api.nvim_create_user_command("LspInfo", lsp_info, {})

local function lsp_start(server_name)
	if server_name then
		pcall(vim.lsp.enable, server_name)
		return
	end
	-- Collect server names from vim.lsp.config
	local names = {}
	for k, v in pairs(vim.lsp.config) do
		if type(v) == "table" and v.cmd then
			table.insert(names, k)
		end
	end
	if #names == 0 then
		vim.notify("No LSP server configurations found", vim.log.levels.WARN)
		return
	end
	table.sort(names)
	vim.ui.select(names, {
		prompt = "LSP Start:",
		format_item = function(item) return item end,
	}, function(choice)
		if choice then
			pcall(vim.lsp.enable, choice)
		end
	end)
end
vim.keymap.set("n", "<leader>ls", lsp_start,   { desc = "LSP Start" })
vim.api.nvim_create_user_command("LspStart", function(opts)
	lsp_start(opts.args ~= "" and opts.args or nil)
end, { nargs = "?" })

local function lsp_stop(identifier)
	if identifier then
		local client_id = tonumber(identifier)
		if client_id then
			local client = vim.lsp.get_client_by_id(client_id)
			if client then client:stop() end
			return
		end
		for _, client in ipairs(vim.lsp.get_clients({ name = identifier })) do
			client:stop()
		end
		return
	end

	local clients = vim.lsp.get_clients()
	if #clients == 0 then
		vim.notify("No active LSP clients", vim.log.levels.INFO)
		return
	end
	vim.ui.select(clients, {
		prompt = "LSP Stop:",
		format_item = function(client)
			return client.name .. " (id " .. client.id .. ")"
		end,
	}, function(choice)
		if choice then
			choice:stop()
		end
	end)
end
vim.keymap.set("n", "<leader>lS", lsp_stop,    { desc = "LSP Stop" })
vim.api.nvim_create_user_command("LspStop", function(opts)
	lsp_stop(opts.args ~= "" and opts.args or nil)
end, { nargs = "?" })

local function lsp_restart(identifier)
	local function restart_by_name(name)
		for _, client in ipairs(vim.lsp.get_clients({ name = name })) do
			client:stop()
		end
		vim.lsp.enable(name)
	end

	if identifier then
		local client_id = tonumber(identifier)
		if client_id then
			local client = vim.lsp.get_client_by_id(client_id)
			if client then restart_by_name(client.name) end
			return
		end
		restart_by_name(identifier)
		return
	end

	local clients = vim.lsp.get_clients()
	if #clients == 0 then
		vim.notify("No active LSP clients", vim.log.levels.INFO)
		return
	end
	vim.ui.select(clients, {
		prompt = "LSP Restart:",
		format_item = function(client)
			return client.name .. " (id " .. client.id .. ")"
		end,
	}, function(choice)
		if choice then
			restart_by_name(choice.name)
		end
	end)
end
vim.keymap.set("n", "<leader>lr", lsp_restart, { desc = "LSP Restart" })
vim.api.nvim_create_user_command("LspRestart", function(opts)
	lsp_restart(opts.args ~= "" and opts.args or nil)
end, { nargs = "?" })

-- Plugins

local qpack = require("qpack")

qpack:add(
	"https://github.com/neovim/nvim-lspconfig",
	function()

		--- Set up an LSP server: define its configuration and enable it only if its binary exists
		---@param server  string The LSP server name (e.g., "eslint") – used as the config key and enable target.
		---@param bin?    string The binary to check for existence (optional, defaults to `server`).
		---@param config? table  Configuration table passed directly to `vim.lsp.config`. See `:h vim.lsp.config()`.
		local function setup_lsp(server, bin, config)
			local bin_to_check = bin or server
			if config then
				vim.lsp.config(server, config)
			end
			if vim.fn.executable(bin_to_check) == 1 then
				vim.lsp.enable(server)
			end
		end

		-- Lua
		setup_lsp("lua_ls", "lua-language-server", { -- TODO: try emmylua
			diagnostics = {
				globals = { "vim" },
			},
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					workspace = {
						checkThirdParty = false,
						library = vim.tbl_filter(
							function(p)
								return p ~= vim.fn.stdpath("config")
							end,
							vim.api.nvim_get_runtime_file("", true)),
						-- library = vim.api.nvim_get_runtime_file("", true),
					},
				}
			}
		})
		setup_lsp("stylua")

		-- Web
		setup_lsp("eslint", "vscode-eslint-language-server", {
			settings = {
				experimental = { useFlatConfig = true },
			},
		})
		setup_lsp("astro", "astro-ls")
		setup_lsp("cssls", "vscode-css-language-server")
		setup_lsp("cssmodules_ls", "cssmodules-language-server")
		setup_lsp("emmet_language_server", "emmet-language-server")
		setup_lsp("graphql", "graphql-lsp")
		setup_lsp("html", "vscode-html-language-server")
		setup_lsp("htmx", "htmx-lsp")
		setup_lsp("oxfmt")
		setup_lsp("oxlint")
		setup_lsp("svelte", "svelte-language-server")
		setup_lsp("tailwindcss", "tailwindcss-language-server")
		-- setup_lsp("ts_ls", "typescript-language-server") -- typescript-tools instead
		setup_lsp("tsgo")
		setup_lsp("turbo_ls", "turbo-language-server")
		setup_lsp("unocss",  "unocss-language-server")
		setup_lsp("vue_ls", "vue-language-server")
		setup_lsp("wc_language_server", "wc-language-server")

		-- Other programming
		setup_lsp("pylsp", nil, { -- alt pyright
			settings = {
				pylsp = {
					plugins = {
						pycodestyle = { enabled = false },
						flake8 = { enabled = true },
						black = { enabled = true },
					},
				},
			},
		})
		setup_lsp("arduino_language_server", "arduino-language-server")
		setup_lsp("autohotkey_lsp", "autohotkey_lsp")
		setup_lsp("awk_ls", "awk-language-server")
		setup_lsp("bashls", "bash-language-server")
		setup_lsp("buf_ls", "buf")
		setup_lsp("csharp_ls")
		setup_lsp("dartls", "dart")
		-- setup_lsp("elixirls") -- have to manually point to bin path
		setup_lsp("fish_lsp", "fish-lsp")
		setup_lsp("fsautocomplete", "fsautocomplete")
		setup_lsp("gdscript")
		setup_lsp("gdshader_lsp", "gdshader-lsp")
		setup_lsp("gleam")
		setup_lsp("gopls")
		setup_lsp("hls", "haskell-language-server-wrapper")
		setup_lsp("java_language_server", "java-language-server")
		setup_lsp("jqls", "jq-lsp")
		setup_lsp("jsonls", "vscode-json-language-server")
		setup_lsp("kotlin_language_server", "kotlin-language-server") -- TODO: replace w/ kotlin_lsp
		setup_lsp("marko-js", "marko-language-server")
		setup_lsp("matlab_ls", "matlab-language-server")
		setup_lsp("mdx_analyzer", "mdx-language-server")
		setup_lsp("nixd") -- nil_ls is alternative
		setup_lsp("nushell", "nu")
		setup_lsp("ocamllsp")
		setup_lsp("ols")
		setup_lsp("opencl_ls", "opencl-language-server")
		setup_lsp("openscad_ls", "openscad-language-server") -- alt openscad_lsp
		setup_lsp("pico8_ls", "pico8-ls")
		setup_lsp("postgres_lsp", "postgres-language-server")
		setup_lsp("powershell_es", "pwsh")
		setup_lsp("qmlls")
		setup_lsp("r_language_server", "R")
		setup_lsp("ruby_lsp", "ruby-lsp")
		-- setup_lsp("rust_analyzer") -- rustacean handles this now
		setup_lsp("scheme_langserver", "scheme-langserver")
		setup_lsp("texlab")
		setup_lsp("tinymist", nil, {

		})
		setup_lsp("zls")

		-- Config languages
		setup_lsp("clangd", nil, {
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--offset-encoding=utf-16",
			}
		})
		setup_lsp("ansiblels", "ansible-language-server")
		setup_lsp("cmake", "cmake")
		setup_lsp("gh_actions_ls", "gh-actions-language-server")
		setup_lsp("gitlab_ci_ls", "gitlab-ci-ls")
		setup_lsp("gradle_ls", "gradle-language-server")
		setup_lsp("home_assistant", "vscode-home-assistant")
		setup_lsp("nginx_language_server", "nginx-language-server")
		setup_lsp("nxls")
		setup_lsp("systemd_lsp", "systemd-lsp")
		setup_lsp("tflint") -- alt terraformls, terraform_lsp
		setup_lsp("tofu_ls", "tofu-ls")
		setup_lsp("vacuum")
		setup_lsp("yamlls", "yaml-language-server")
	end
)

if vim.fn.executable("rust-analyzer") == 1 then
	qpack:add(
		{
			{
				src = "https://github.com/mrcjkb/rustaceanvim",
				version = vim.version.range("^9")
			},
			"https://github.com/Saecki/crates.nvim",
		},
		function()
			-- Any rustacean specific keymaps etc here
			vim.api.nvim_create_autocmd("LspAttach", {
				group = lsp_group,
				desc = "LSP Actions",
				callback = function(ev)
					local bufnr = ev.buf
					local client_id = ev.data.client_id
					local client = vim.lsp.get_client_by_id(client_id)

					if client and client.name == "rust-analyzer" then
						vim.keymap.set("n", "<leader>rx", function() vim.cmd.RustLsp("expandMacro") end, {
							buffer = bufnr,
							desc = "Expand macro",
						})
					end
				end,
			})

			local has_crates, crates = pcall(require, "crates")
			if not has_crates then return end
			crates.setup()
		end
	)
end

if vim.fn.executable("tinymist") == 1 and vim.fn.executable("websocat") == 1 then
	qpack:add(
		{ src = "https://github.com/chomosuke/typst-preview.nvim", version = "1.*" },
		function()
			local has_t_preview, t_preview = pcall(require, "typst-preview")
			if not has_t_preview then return end
			t_preview.setup({
				dependencies_bin = { -- prevent auto-download of bin
					["tinymist"] = "tinymist",
					["websocat"] = "websocat",
				},
				follow_cursor = false,
			})
		end
	)
end

if vim.fn.executable("node") == 1 and vim.fn.executable("typescript-language-server") == 1 then
	qpack:add(
		{
			"https://github.com/nvim-lua/plenary.nvim",
			"https://github.com/pmizio/typescript-tools.nvim"
		},
		function()
			local has_ts_tools, ts_tools = pcall(require, "typescript-tools")
			if not has_ts_tools then return end
			-- TODO: add the stuff for organised imports
			ts_tools.setup({
				settings = {
					tsserver_plugins = {},
					separate_diagnostic_server = true,
					tsserver_max_memory = nil,
				},
			})

			-- TODO: Test the scuffed ts errors stuff
			--- Small module to prettify TS error messages without external dependencies
			local function prettify_ts_error(msg)
				msg = msg:gsub('({)([^}]+)(})', function(open, body, close)
					local parts = {}
					for part in body:gmatch('[^;]+') do
						local t = vim.trim(part)
						if t ~= '' then table.insert(parts, '  ' .. t) end
					end
					if #parts > 1 then
						return '#[ts-error]\n' .. table.concat(parts, '\n') .. '\n'
					end
					return open .. body .. close
				end)
				-- Collapse multi-line back into single line for picker display
				msg = msg:gsub('\n', '⏎ ')
				-- Truncate
				if #msg > 120 then msg = msg:sub(1, 117) .. '...' end
				return msg
			end
		end
	)
end
