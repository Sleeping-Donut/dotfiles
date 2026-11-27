local lsp_group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP Actions",
	group = lsp_group,
	callback = function(ev)
		local bufnr = ev.buf
		local client_id = ev.data.client_id
		local client = vim.lsp.get_client_by_id(client_id)
		if not client then return end

		-- Native completion fed by LSP; triggered manually via <C-x><C-o>
		vim.lsp.completion.enable(true, client_id, bufnr, { autotrigger = false })

		-- Native formatting fed by LSP
		-- triggered for range with gq
		-- triggered for buf with <leader>f
		if client:supports_method("textDocument/formatting") then
			vim.keymap.set("n", "<leader>f", function()
				vim.lsp.buf.format({
					bufnr = bufnr,
					id = client_id,
					timeout_ms = 3000,
				})
			end, { buffer = bufnr, desc = "Format" })
		end
	end,
})

vim.keymap.set("n", "<leader>th", function()
	local enabled = not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
    vim.lsp.inlay_hint.enable(enabled, { bufnr = 0 })
	vim.notify("Inlay hints: " .. (enabled and "on" or "off"), vim.log.levels.INFO)
end, { desc = "Toggle Inlay Hints" })

local function float_geometry(line_count, max_width)
	local width = math.min(max_width, math.max(20, vim.o.columns - 4))
	local height = math.min(line_count + 2, math.max(5, vim.o.lines - 4))
	local col = math.max(0, math.floor((vim.o.columns - width) / 2))
	local row = math.max(0, math.floor((vim.o.lines - height) / 2))
	return width, height, row, col
end

local function ts_info()
	local ft = vim.bo.filetype
	if ft == "" then
		vim.notify("No filetype detected", vim.log.levels.WARN)
		return
	end

	local ok_parser, parser = pcall(vim.treesitter.get_parser, 0, ft)
	local has_parser = ok_parser and parser ~= nil
	local ok_hl, hl_files = pcall(vim.treesitter.query.get_files, ft, "highlights")
	local has_highlights = ok_hl and hl_files and #hl_files > 0

	local lines = {
		"# Treesitter Status",
		"",
		"Filetype: "..ft,
		"Parser loaded: "..(has_parser and "✔" or "✘"),
		"Language: "..(has_parser and parser:lang() or ft),
		"Highlights: "..(has_highlights and "✔" or "✘"),
	}

	-- List installed parsers
	local installed = {}
	for _, rtp in ipairs(vim.api.nvim_list_runtime_paths()) do
		local dir = vim.fs.joinpath(rtp, "parser")
		if vim.fn.isdirectory(dir) == 1 then
			for _, f in ipairs(vim.fn.readdir(dir)) do
				local name = f:match("(.*)%.so$") or f:match("(.*)%.dylib$")
				if name then installed[name] = true end
			end
		end
	end
	local names = {}
	for lang in ipairs(installed) do
		table.insert(names, lang)
	end
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
	local width, height, row, col = float_geometry(#lines, 50)
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
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
	local width, height, row, col = float_geometry(#lines, 80)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
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
		vim.notify("No LSP server configurations found", vim.log.levels.INFO)
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

local function resolve_clients(identifier, prompt, on_select)
	if identifier then
		local id = tonumber(identifier)
		if id then
			local client = vim.lsp.get_client_by_id(id)
			if client then on_select({ client }) end
			return
		end
		local matches = vim.lsp.get_clients({ name = identifier })
		if #matches > 0 then on_select(matches) end
		return
	end

	local clients = vim.lsp.get_clients()
	if #clients == 0 then
		vim.notify("No active LSP clients", vim.log.levels.INFO)
		return
	end

	vim.ui.select(clients, {
		prompt = prompt,
		format_item = function(client)
			return string.format("%s (id %d)", client.name, client.id)
		end,
	}, function(choice)
		if choice then
			on_select({ choice })
		end
	end)
end

local function lsp_stop(identifier)
	resolve_clients(identifier, "LSP Stop:", function(clients)
		for _, client in ipairs(clients) do
			client:stop()
		end
	end)
end
vim.keymap.set("n", "<leader>lS", lsp_stop,    { desc = "LSP Stop" })
vim.api.nvim_create_user_command("LspStop", function(opts)
	lsp_stop(opts.args ~= "" and opts.args or nil)
end, { nargs = "?" })

local function lsp_restart(identifier)
	resolve_clients(identifier, "LSP Restart:", function(clients)
		local names = {}
		for _, client in ipairs(clients) do
			names[client.name] = true
			client:stop()
		end
		for name in pairs(names) do
			vim.lsp.enable(name)
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

		---@class LspServerSpec
		---@field bin? string Executable name to check (defaults to server name)
		---@field config? table Configuration table passed to `vim.lsp.config`

		---@type table<string, LspServerSpec>
		local servers = {
			-- Lua & Formatting
			lua_ls = {
				bin = "lua-language-server",
				config = {
					diagnostics = {
						globals = { "vim" },
					},
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							workspace = {
								checkThirdParty = false,
								library = vim.tbl_filter(function(p)
									return p ~= vim.fn.stdpath("config")
								end, vim.api.nvim_get_runtime_file("", true)),
							},
						},
					},
				},
			},
			stylua = {},

			-- Web
			eslint = {
				bin = "vscode-eslint-language-server",
				config = {
					settings = {
						experimental = { useFlatConfig = true },
					},
				},
			},
			astro = { bin = "astro-ls" },
			cssls = { bin = "vscode-css-language-server" },
			cssmodules_ls = { bin = "cssmodules-language-server" },
			emmet_language_server = { bin = "emmet-language-server" },
			graphql = { bin = "graphql-lsp" },
			html = { bin = "vscode-html-language-server" },
			htmx = { bin = "htmx-lsp" },
			oxfmt = {},
			oxlint = {},
			svelte = { bin = "svelte-language-server" },
			tailwindcss = { bin = "tailwindcss-language-server" },
			tsgo = {},
			turbo_ls = { bin = "turbo-language-server" },
			unocss = { bin = "unocss-language-server" },
			vue_ls = { bin = "vue-language-server" },
			wc_language_server = { bin = "wc-language-server" },

			-- Other Programming
			pylsp = {
				config = {
					settings = {
						pylsp = {
							plugins = {
								pycodestyle = { enabled = false },
								flake8 = { enabled = true },
								black = { enabled = true },
							},
						},
					},
				},
			},
			arduino_language_server = {},
			autohotkey_lsp = {},
			awk_ls = { bin = "awk-language-server" },
			bashls = { bin = "bash-language-server" },
			buf_ls = { bin = "buf" },
			csharp_ls = {},
			dartls = { bin = "dart" },
			fish_lsp = { bin = "fish-lsp" },
			fsautocomplete = {},
			gdscript = {},
			gdshader_lsp = { bin = "gdshader-lsp" },
			gleam = {},
			gopls = {},
			hls = { bin = "haskell-language-server-wrapper" },
			java_language_server = {},
			jqls = { bin = "jq-lsp" },
			jsonls = { bin = "vscode-json-language-server" },
			kotlin_language_server = {},
			["marko-js"] = { bin = "marko-language-server" },
			matlab_ls = { bin = "matlab-language-server" },
			mdx_analyzer = { bin = "mdx-language-server" },
			nixd = {},
			nushell = { bin = "nu" },
			ocamllsp = {},
			ols = {},
			opencl_ls = { bin = "opencl-language-server" },
			openscad_ls = { bin = "openscad-language-server" },
			pico8_ls = { bin = "pico8-ls" },
			postgres_lsp = { bin = "postgres-language-server" },
			powershell_es = { bin = "pwsh" },
			qmlls = {},
			r_language_server = { bin = "R" },
			ruby_lsp = { bin = "ruby-lsp" },
			scheme_langserver = {},
			texlab = {},
			tinymist = {},
			zls = {},

			-- Config & Infra
			clangd = {
				config = {
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--offset-encoding=utf-16",
					},
				},
			},
			ansiblels = { bin = "ansible-language-server" },
			cmake = {},
			gh_actions_ls = { bin = "gh-actions-language-server" },
			gitlab_ci_ls = { bin = "gitlab-ci-ls" },
			gradle_ls = { bin = "gradle-language-server" },
			home_assistant = { bin = "vscode-home-assistant" },
			nginx_language_server = { bin = "nginx-language-server" },
			nxls = {},
			systemd_lsp = { bin = "systemd-lsp" },
			tflint = {},
			tofu_ls = { bin = "tofu-ls" },
			vacuum = {},
			yamlls = { bin = "yaml-language-server" },
		}

		for server, spec in pairs(servers) do
			if spec.config then
				vim.lsp.config(server, spec.config)
			end
			local bin = spec.bin or server
			if vim.fn.exepath(bin) ~= "" then
				vim.lsp.enable(server)
			end
		end

		-- lua: config.settings.Lua.workspace.library -alt-> vim.api.nvim_get_runtime_file("", true)
		-- lua: try emmylua
		-- typescript: typescript_tools instead of direct ts_ls
		-- elixir: elixrls but needs manual point to bin path so only add when useful
		-- kotlin: current is kotlin-language-server but move to kotlin_lsp later
		-- nix: nixd but alt is nil_ls
		-- rust: rustacean instead of direct rust-analyzer
		-- terraform: tflint but alt is terraformls or terraform_lsp
	end
)

---@param bins string[]
---@return boolean
local function has_all_bins(bins)
	for _, bin in ipairs(bins) do
		if vim.fn.exepath(bin) == "" then
			return false
		end
	end
	return true
end

-- Rust
if has_all_bins({ "rust-analyzer" }) then
	qpack:add(
		{
			{
				src = "https://github.com/mrcjkb/rustaceanvim",
				version = vim.version.range("^9"),
			},
			"https://github.com/Saecki/crates.nvim",
		},
		function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = lsp_group,
				desc = "Rust LSP keymaps",
				callback = function(ev)
					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					if client and client.name == "rust-analyzer" then
						vim.keymap.set("n", "<leader>rx", function()
							vim.cmd.RustLsp("expandMacro")
						end, {
							buffer = ev.buf,
							desc = "Expand macro",
						})
					end
				end,
			})

			local ok_crates, crates = pcall(require, "crates")
			if ok_crates then
				crates.setup({})
			end
		end
	)
end

-- Typst
if has_all_bins({ "tinymist", "websocat" }) then
	qpack:add(
		"https://github.com/chomosuke/typst-preview.nvim",
		function()
			local ok_preview, t_preview = pcall(require, "typst-preview")
			if not ok_preview then
				return
			end

			t_preview.setup({
				dependencies_bin = {
					["tinymist"] = "tinymist",
					["websocat"] = "websocat",
				},
				follow_cursor = false,
			})

			vim.api.nvim_create_user_command("TypstPreviewStopAll", function()
				local count = 0
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "typst" then
						vim.api.nvim_buf_call(buf, function()
							pcall(function()
								vim.cmd("silent! TypstPreviewStop")
							end)
						end)
						count = count + 1
					end
				end
				vim.schedule(function()
					vim.notify(
						string.format("Called Stop on %d Typst preview buffer session(s)", count),
						vim.log.levels.INFO
					)
				end)
			end, { desc = "Stop all active typst-preview instances" })
		end
	)
end

-- TypeScript / JavaScript
if has_all_bins({ "node", "typescript-language-server" }) then
	qpack:add(
		{
			"https://github.com/nvim-lua/plenary.nvim",
			"https://github.com/pmizio/typescript-tools.nvim",
		},
		function()
			local ok_ts_tools, ts_tools = pcall(require, "typescript-tools")
			if not ok_ts_tools then
				return
			end

			ts_tools.setup({
				settings = {
					tsserver_plugins = {},
					separate_diagnostic_server = true,
					tsserver_max_memory = nil,
				},
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = lsp_group,
				desc = "typescript-tools keymaps",
				callback = function(ev)
					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					if not client or client.name ~= "typescript-tools" then
						return
					end

					---@diagnostic disable-next-line: unused-local
					local opts = { buffer = ev.buf }
				end,
			})

			-- TODO: Test prettify_ts_error against real TS diagnostic messages
			---@diagnostic disable-next-line: unused-local, unused-function
			local function prettify_ts_error(msg)
				msg = msg:gsub("({)([^}]+)(})", function(open, body, close)
					local parts = {}
					for part in body:gmatch("[^;]+") do
						local t = vim.trim(part)
						if t ~= "" then
							table.insert(parts, "  " .. t)
						end
					end
					if #parts > 1 then
						return "#[ts-error]\n" .. table.concat(parts, "\n") .. "\n"
					end
					return open .. body .. close
				end)
				msg = msg:gsub("\n", "⏎ ")
				if #msg > 120 then
					msg = msg:sub(1, 117) .. "..."
				end
				return msg
			end
		end
	)
end

