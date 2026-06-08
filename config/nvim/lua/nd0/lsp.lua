local lsp_group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP Actions",
	group = lsp_group,
	callback = function(ev)
		local bufnr = ev.buf
		local client_id = ev.data.client_id
		local client = vim.lsp.get_client_by_id(client_id)

		vim.lsp.completion.enable(true, client_id, bufnr, { autotrigger = false })
		vim.keymap.set("n", "K", function() vim.lsp.buf.hover({
			border = "solid",
		}) end, {
			buffer = bufnr,
			desc = "LSP hover"
		})
		if client and client.server_capabilities.inlayHintProvider then
			local default_inlay = false
			vim.lsp.inlay_hint.enable(default_inlay, { bufnr = bufnr })
		end
		if client and client.server_capabilities.documentFormattingProvider then
			vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({
				bufnr = bufnr,
				id = client_id,
				timeout_ms = 1000 * 3
			}) end, {
				buffer = bufnr,
				desc = "Format",
			})
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
		---Enable an LSP server only if its binary exists on the system.
		---@param server string The name of the LSP configuration (e.g., "lua_ls")
		---@param bin? string The name of the binary to check (optional, defaults to server)
		local function lsp_enable(server, bin)
			-- If bin is nil, fallback to server name
			local binary_to_check = bin or server

			if vim.fn.executable(binary_to_check) == 1 then
				vim.lsp.enable(server)
			end
		end

		-- Lua
		vim.lsp.config("lua_ls", {
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
		lsp_enable("lua_ls", "lua-language-server") -- TODO: try emmylua
		lsp_enable("stylua")

		-- Web
		vim.lsp.config("eslint", {
			settings = {
				experimental = { useFlatConfig = true },
			},
		})
		lsp_enable("astro", "astro-ls")
		lsp_enable("cssls", "vscode-css-language-server")
		lsp_enable("cssmodules_ls", "cssmodules-language-server")
		lsp_enable("emmet_language_server", "emmet-language-server")
		lsp_enable("eslint", "vscode-eslint-language-server")
		lsp_enable("graphql", "graphql-lsp")
		lsp_enable("html", "vscode-html-language-server")
		lsp_enable("htmx", "htmx-lsp")
		lsp_enable("oxfmt")
		lsp_enable("oxlint")
		lsp_enable("svelte", "svelte-language-server")
		lsp_enable("tailwindcss", "tailwindcss-language-server")
		-- lsp_enable("ts_ls", "typescript-language-server") -- typescript-tools instead
		lsp_enable("tsgo")
		lsp_enable("turbo_ls", "turbo-language-server")
		lsp_enable("unocss",  "unocss-language-server")
		lsp_enable("vue_ls", "vue-language-server")
		lsp_enable("wc_language_server", "wc-language-server")

		-- Other programming
		vim.lsp.config("pylsp", {
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
		lsp_enable("arduino_language_server", "arduino-language-server")
		lsp_enable("autohotkey_lsp", "autohotkey_lsp")
		lsp_enable("awk_ls", "awk-language-server")
		lsp_enable("bashls", "bash-language-server")
		lsp_enable("buf_ls", "buf")
		lsp_enable("csharp_ls")
		lsp_enable("dartls", "dart")
		-- lsp_enable("elixirls") -- have to manually point to bin path
		lsp_enable("fish_lsp", "fish-lsp")
		lsp_enable("fsautocomplete", "fsautocomplete")
		lsp_enable("gdscript")
		lsp_enable("gdshader_lsp", "gdshader-lsp")
		lsp_enable("gleam")
		lsp_enable("gopls")
		lsp_enable("hls", "haskell-language-server-wrapper")
		lsp_enable("java_language_server", "java-language-server")
		lsp_enable("jqls", "jq-lsp")
		lsp_enable("jsonls", "vscode-json-language-server")
		lsp_enable("kotlin_language_server", "kotlin-language-server") -- TODO: replace w/ kotlin_lsp
		lsp_enable("marko-js", "marko-language-server")
		lsp_enable("matlab_ls", "matlab-language-server")
		lsp_enable("mdx_analyzer", "mdx-language-server")
		lsp_enable("nixd") -- nil_ls is alternative
		lsp_enable("nushell", "nu")
		lsp_enable("ocamllsp")
		lsp_enable("ols")
		lsp_enable("opencl_ls", "opencl-language-server")
		lsp_enable("openscad_ls", "openscad-language-server") -- alt openscad_lsp
		lsp_enable("pico8_ls", "pico8-ls")
		lsp_enable("postgres_lsp", "postgres-language-server")
		lsp_enable("powershell_es", "pwsh")
		lsp_enable("pylsp") -- alt pyright
		lsp_enable("qmlls")
		lsp_enable("r_language_server", "R")
		lsp_enable("ruby_lsp", "ruby-lsp")
		-- lsp_enable("rust_analyzer") -- rustacean handles this now
		lsp_enable("scheme_langserver", "scheme-langserver")
		lsp_enable("texlab", "texlab")
		lsp_enable("tinymist", "tinymist")
		lsp_enable("zls")

		-- Config languages
		vim.lsp.config("clangd", {
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--offset-encoding=utf-16",
			}
		})
		lsp_enable("ansiblels", "ansible-language-server")
		lsp_enable("clangd")
		lsp_enable("cmake", "cmake")
		lsp_enable("gh_actions_ls", "gh-actions-language-server")
		lsp_enable("gitlab_ci_ls", "gitlab-ci-ls")
		lsp_enable("gradle_ls", "gradle-language-server")
		lsp_enable("home_assistant", "vscode-home-assistant")
		lsp_enable("nginx_language_server", "nginx-language-server")
		lsp_enable("nxls")
		lsp_enable("systemd_lsp", "systemd-lsp")
		lsp_enable("tflint") -- alt terraformls, terraform_lsp
		lsp_enable("tofu_ls", "tofu-ls")
		lsp_enable("vacuum")
		lsp_enable("yamlls", "yaml-language-server")
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

if vim.fn.executable("node") == 1 then
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
