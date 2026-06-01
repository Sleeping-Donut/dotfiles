local qpack = require("qpack")
-- TODO: add healthcheck for plugins

qpack:add(
	"https://github.com/j-hui/fidget.nvim",
	function()
		local has_fidget, fidget = pcall(require, "fidget")
		if not has_fidget then return end
		fidget.setup({})
	end
)

qpack:add(
	"https://github.com/mbbill/undotree",
	function()
		-- Looks like it loads this too late but its fine since it checks the var on each run
		vim.g.undotree_WindowLayout = 4
		vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, {desc = "Toggle undo tree"})
	end
)

qpack:add(
	"https://github.com/stevearc/oil.nvim",
	function()
		local has_oil, oil = pcall(require, "oil")
		if not has_oil then return end
		oil.setup()
		vim.keymap.set("n", "<leader>pv", vim.cmd.Oil, { desc = "Open parent direcory (oil)" })
		-- NOTE: when netrw replacement is added consider removing
	end
)

qpack:add(
	{
		{
			src = "https://github.com/ThePrimeagen/harpoon",
			version = "harpoon2"
		},
		"https://github.com/nvim-lua/plenary.nvim",
	},
	function()
		local has_harpoon, harpoon = pcall(require, "harpoon")
		if not has_harpoon then
			return
		end

		harpoon:setup({
			settings = {
				save_on_toggle = true,
				sync_on_close = true,
			}
		})

		-- TODO: do a QWERTY / DVORK switcher
		local kb_map = {
			qwerty = {"h","j","k","l"},
			dvorak = {"d","h","t","n",}
		}
		local kb = kb_map.qwerty
		vim.keymap.set("n", "<leader>ha",
			function() harpoon:list():add() end,
			{desc = "Harpoon add to list"})
		vim.keymap.set("n", "<C-e>",
			function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
			{desc = "Harpoon toggle quick menu"})
		vim.keymap.set("n", "<C-"..kb[1]..">",
			function() harpoon:list():select(1) end,
			{desc = "Harpoon select 1"})
		vim.keymap.set("n", "<C-"..kb[2]..">",
			function() harpoon:list():select(2) end,
			{desc = "Harpoon select 2"})
		vim.keymap.set("n", "<C-"..kb[3]..">",
			function() harpoon:list():select(3) end,
			{desc = "Harpoon select 3"})
		vim.keymap.set("n", "<C-"..kb[4]..">",
			function() harpoon:list():select(4) end,
			{desc = "Harpoon select 4"})
	end
)

-- mini icons
qpack:add(
	"https://github.com/nvim-mini/mini.icons",
	function()
		local has_icons, icons = pcall(require, "mini.icons")
		if not has_icons then return end
		icons.setup()
	end
)

-- mini git
qpack:add(
	"https://github.com/nvim-mini/mini-git",
	function()
		local has_minigit, minigit = pcall(require, "mini-git")
		if not has_minigit then return end
		minigit.setup()
	end
)

-- mini diff
qpack:add(
	"https://github.com/nvim-mini/mini.diff",
	function()
		local has_minidiff, minidiff = pcall(require, "mini.diff")
		if not has_minidiff then return end
		minidiff.setup()
	end
)

-- mini hipatterns
qpack:add(
	"https://github.com/nvim-mini/mini.hipatterns",
	function()
		local has_hipatterns, hipatterns = pcall(require, "mini.hipatterns")
		if not has_hipatterns then return end
		hipatterns.setup({
			highlighters = {
				fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
				hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
				todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
				note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

				hex_color = hipatterns.gen_highlighter.hex_color(),
			}
		})
	end
)

-- status
qpack:add(
	"https://github.com/echasnovski/mini.statusline",
	function()
		local has_status, statusline = pcall(require, "mini.statusline")
		if not has_status then
			return
		end

		vim.opt.showmode = false

		local has_icons = pcall(require, "mini.icons")
		local has_git = pcall(require, "mini.git")
		local has_diff = pcall(require, "mini.diff")

		--- Get status of LSP for current buffer
		---@return "☐" | "⊡" | "☒"
		local function get_lsp_status()
			local bufnr = vim.api.nvim_get_current_buf()

			-- State 1: LSP Off (Empty filetype)
			if vim.bo[bufnr].filetype == "" then
				return "☐"
			end

			-- State 2: LSP Running (At least one client attached)
			local clients = vim.lsp.get_clients({ bufnr = bufnr })
			if #clients > 0 then
				return "⊡"
			end

			-- State 3: No LSP Found (Filetype exists but no server attached)
			return "☒"
		end

		statusline.setup({
			use_icons = has_icons,
			content = {
				active = function()
					local mode, mode_hl = MiniStatusline.section_mode({
						trunc_width = 99999, -- ensure mode gets truncated
						format = function(mode_info)
							return mode_info.short
						end,
					})
					local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
					local git = has_git and MiniStatusline.section_git({ trunc_width = 75 }) or ""
					local diff = has_diff and MiniStatusline.section_diff({ trunc_width = 75 }) or ""

					local filename = MiniStatusline.section_filename({ trunc_width = 140 })
					local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
					local location = MiniStatusline.section_location({ trunc_width = 75 })

					local lsp_status = get_lsp_status()
					local lsp_details = MiniStatusline.section_lsp({ trunc_width = 75 })

					return MiniStatusline.combine_groups({
						{ hl = mode_hl, strings = {mode} },
						{ hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics } },
						"%<",
						{ hl = "MiniStatuslineFilename", strings = { filename } },
						"%=",
						{ hl = "MiniStatuslineFileinfo", strings = { lsp_status, fileinfo } },
						{ hl = mode_hl, strings = { lsp_details, location } },
					})
				end,
			},
		})
	end
)

qpack:add(
	{
		"https://github.com/nvim-treesitter/nvim-treesitter",
		"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
	},
	function()
		local has_ts, ts = pcall(require, "nvim-treesitter")
		if not has_ts then return end
		ts.setup({
			auto_install = false,
			highlight = { enable = true },
		})
		local has_tso, tso = pcall(require, "nvim-treesitter-textobjects")
		if not has_tso then return end
		tso.setup({
			select = {
				enable = true,
			},
		})
	end
)

qpack:add(
	"https://github.com/nvim-treesitter/nvim-treesitter-context",
	function()
		local has_ts_context, ts_context = pcall(require, "nvim-treesitter-context")
		if not has_ts_context then
			return
		end
		ts_context.setup({ multiline_threshold = 20 })
	end
)

qpack:add(
	"https://github.com/nvim-mini/mini.ai",
	function()
		local has_miniai, miniai = pcall(require, "mini.ai")
		if not has_miniai then return end

		local config = {
			mappings = {
				around_next = "an",
				inside_next = "in",
				around_last = "al",
				inside_last = "il",
				goto_left = "[",
				goto_right = "]",
			}
		}
		local has_treesitter = pcall(require, "nvim-treesitter")
		local has_ts_tobjects = pcall(require, "nvim-treesitter-textobjects")
		if has_treesitter and has_ts_tobjects then
			config.custom_textobjects = {
				f = miniai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
				c = miniai.gen_spec.treesitter({ a = "@class.outer",    i = "@class.inner"    }),
				o = miniai.gen_spec.treesitter({
					a = { "@conditional.outer", "@loop.outer" },
					i = { "@conditional.inner", "@loop.inner" },
				}),
			}
		end

		miniai.setup(config)
	end
)

qpack:add(
	"https://github.com/nvim-mini/mini.surround",
	function()
		local has_surround, surround = pcall (require, "mini.surround")
		if not has_surround then
			return
		end
		surround.setup()
	end
)

qpack:add(
	{
		"https://github.com/nvim-mini/mini.pick",
		"https://github.com/nvim-mini/mini.extra",
		"https://github.com/nvim-mini/mini.visits",
	},
	function()
		local has_pick, pick = pcall(require, "mini.pick")
		if not has_pick then return end
		pick.setup({
			options = { use_icons = true },
			window = {
				config = function()
					local pad = 2
					return {
						border = "solid",
						width = vim.o.columns - 2 * pad - 2,
						col = pad,
					}
				end,
				-- prompt_caret = "│",
				-- prompt_prefix = "",
			},
			mappings = {
				-- scroll_view_up = {
				-- 	char = "<C-u>",
				-- 	func = function() pick.builtin.buffers end,
				-- },
				-- scroll_view_down = {
				-- 	char = "<C-d>",
				-- 	func = function() pick.actions.scroll_view("down") end,
				-- },
				-- toggle_preview = "",
				-- toggle_info = "",
			},
		})

		local has_extra, extra = pcall(require, "mini.extra")
		if not has_extra then return end
		extra.setup()

		-- Helper for specialized file picking
		---@param current_dir boolean? If true, sets cwd to current file's directory
		local function pick_files(current_dir, hidden)
			local cwd = current_dir and vim.fn.expand("%:p:h") or vim.fn.getcwd()
			-- if cwd == "" then cwd = vim.fn.getcwd() end
			local has_fd = vim.fn.executable("fd") == 1
			local args = {}
			if has_fd then
				args = hidden and { "--hidden", "--no-ignore" } or {}
			else
				args = { ".", "-type", "f" }
			end

			pick.builtin.files(
				{ tool = has_fd and "fd" or "find" },
				{ source = { cwd = cwd, args = args } }
			)
		end

		--- Helper for picking colorschemes with live preview and abort-revert
		local function pick_colorscheme()
			local og_theme = vim.g.colors_name
			local function apply_theme(theme) pcall(vim.cmd.colorscheme, theme) end

			local chosen_theme = pick.start({
				source = {
					name = "Colorschemes",
					items = vim.fn.getcompletion("", "color"),
					preview = function(_, item)
						if item then apply_theme(item) end
					end,
					choose = function(item) apply_theme(item) end,
				}
			})

			if not chosen_theme then apply_theme(og_theme) end
		end

		vim.keymap.set("n", "<leader>tf", function() pick_files() end, { desc = "Pick files" })
		vim.keymap.set("n", "<leader>tF", function() pick_files(false, true) end, { desc = "Pick files (hidden)" })
		vim.keymap.set("n", "<leader>t.", function() pick_files(true) end, { desc = "Pick files from current file location (hidden)" })
		vim.keymap.set("n", "<leader>t,", function() pick_files(true, true) end, { desc = "Pick files from current file location (hidden)" })

		vim.keymap.set("n", "<leader>tr", function() pick.builtin.grep_live() end, { desc = "Pick grep" })
		vim.keymap.set("n", "<leader>tR", function() pick.builtin.grep_live({
			tool = { args = { "--hidden", "--no-ignore", "--smart-case" } }
		}) end, { desc = "Pick grep hidden" })

		vim.keymap.set("n", "<leader>tg", function() extra.pickers.git_files() end, { desc = "Git files" })
		vim.keymap.set("n", "<leader>tvs", function() extra.pickers.git_status() end, { desc = "Git status" })

		vim.keymap.set("n", "<leader>gtd", function() extra.pickers.lsp({ scope = "definition" }) end, { desc = "Pick LSP definition" })
		vim.keymap.set("n", "<leader>vtrr", function() extra.pickers.lsp({ scope = "references" }) end, { desc = "Pick LSP reference" })
		vim.keymap.set("n", "<leader>tld", function() extra.pickers.diagnostic({ scope = "current" }) end, { desc = "Pick LSP diagnostic" })

		vim.keymap.set("n", "<leader>tvb", function() extra.pickers.git_branches() end,
			{ desc = "Git Branches" })

		vim.keymap.set("n", "<leader>t;", function() extra.pickers.visit_paths() end, { desc = "Visit paths" })

		vim.keymap.set("n", "<leader>tc", function() pick_colorscheme() end, { desc = "Pick colorscheme" })

		-- LSP Pickers
		vim.keymap.set("n", "<leader>vtrr", function() extra.pickers.lsp({ scope = "references" }) end,
			{ desc = "LSP References" })
		vim.keymap.set("n", "<leader>tlD", function() extra.pickers.diagnostic() end,
			{ desc = "LSP Diagnostics" })
		vim.keymap.set("n", "<leader>gti", function() extra.pickers.lsp({ scope = "implementation" }) end,
			{ desc = "LSP Implementations" })
		vim.keymap.set("n", "<leader>gtd", function() extra.pickers.lsp({ scope = "definition" }) end,
			{ desc = "LSP Definitions" })
		vim.keymap.set("n", "<leader>gto", function() extra.pickers.lsp({ scope = "type_definition" }) end,
			{ desc = "LSP Type Definition" })
		vim.keymap.set("n", "<leader>vtws", function() extra.pickers.lsp({ scope = "workspace_symbol" }) end,
			{ desc = "LSP Workspace Symbols" })
		vim.keymap.set("n", "<leader>vtbs", function() extra.pickers.lsp({ scope = "document_symbol" }) end,
			{ desc = "LSP Document Symbols" })

		local function pick_keymaps()
			local raw = {}
			for _, mode in ipairs({ "n", "v", "i", "x", "s", "o" }) do
				for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
					local desc = m.desc or ""
					local rhs = m.rhs or ""
					if desc ~= "" and rhs ~= "<Nop>" then
						local key = m.lhs .. "|" .. desc
						if not raw[key] then raw[key] = { modes = {}, lhs = m.lhs, desc = desc, rhs = rhs, buffer = m.buffer } end
						raw[key].modes[#raw[key].modes + 1] = mode
					end
				end
			end
			-- local items = {}
			-- local modes = { "n", "v", "i", "x", "s", "o" }
			-- for _, mode in ipairs(modes) do
			-- 	for _, km in ipairs(vim.api.nvim_get_keymap(mode)) do
			-- 		local desc = km.desc or ""
			-- 		local rhs = km.rhs or ""
			-- 		if desc ~= "" and rhs ~= "<Nop>" then
			-- 			table.insert(items, {
			-- 				mode = mode,
			-- 				lhs = km.lhs,
			-- 				desc = desc,
			-- 				buffer = km.buffer,
			-- 				rhs = rhs,
			-- 			})
			-- 		end
			-- 	end
			-- end
			local items = vim.tbl_values(raw)
			table.sort(items, function(a,b) return a.lhs < b.lhs end)
			local function display_lhs(lhs)
				return lhs
					:gsub(" ", "<Space>")
					:gsub("\t", "<Tab>")
					:gsub("\n", "<CR>")
				end
			pick.start({
				source = {
					name = "Current Keymaps",
					items = items,
					show = function(buf_id, shown, _query)
						for i, item in ipairs(shown) do
							local modes = table.concat(item.modes, ",")
							local line = modes
								.."       "..display_lhs(item.lhs)
								.."    "..item.desc
							vim.api.nvim_buf_set_lines(buf_id, i - 1, i, false, { line })
						end
					end,
					preview = function(buf_id, item)
						if not item then return end
						local lines = {
							"# "..display_lhs(item.lhs),
							"",
							"Mode:     "..item.mode,
							"Desc:     "..item.desc,
						}
						if item.buffer and item.buffer > 0 then
							table.insert(lines, "Buffer:   yes")
						end
						if item.rhs and item.rhs ~= "" then
							table.insert(lines, "")
							table.insert(lines, "RHS:   "..item.rhs)
						end
						vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
					end,
					choose = function(_) end,
				},
			})
		end
		local function pick_keymaps_defaults()
			local has_keymaps, default_keymaps = pcall(require, "nd0.new.default_keymaps")
			if not has_keymaps then return end
			pick.start({
				source = {
					name = "Default Keymaps",
					items = default_keymaps,
					show = function(buf_id, items, _query)
						for i, item in ipairs(items) do
							local line = item.lhs.." - "..item.desc
							vim.api.nvim_buf_set_lines(buf_id, i - 1, i, false, { line })
						end
					end,
					preview = function(buf_id, item)
						if not item then return end
						local lines = {
							"# "..item.lhs,
							"",
							item.desc,
							"",
							"---",
							"",
							"Info: `:h "..item.help.."`",
							"",
							"Press <CR> to open full help page",
						}
						vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
					end,
					choose = function(item)
						vim.defer_fn(function()
							vim.cmd.help(item.help)
						end, 50)
					end,
				}
			})
		end
		vim.keymap.set("n", "<leader>tk", function() pick_keymaps_defaults() end, {desc = "Default keymaps"})
		vim.keymap.set("n", "<leader>tK", function() pick_keymaps() end, {desc = "Keymaps"})
	end
)

qpack:add(
	"https://github.com/dinhhuy258/git.nvim",
	function()
		local has_git_fug, git_fug = pcall(require, "git")
		if not has_git_fug then return end
		git_fug.setup()
	end
)

--- Language specific stuff

qpack:add("https://github.com/ellisonleao/gruvbox.nvim")

qpack:add("https://github.com/catppuccin/nvim")

qpack:add(
	"https://github.com/folke/tokyonight.nvim",
	function()
		local has_tokyo, tokyonight = pcall(require, "tokyonight")
		if not has_tokyo then return end
		tokyonight.setup({
			style = "night",
			light_style = "storm",
			transparent = false,
			terminal_colors = true,
		})
	end
)

qpack:add(
	"https://github.com/rose-pine/neovim",
	function()
		local has_rose, rose_pine = pcall(require, "rose-pine")
		if not has_rose then return end
		rose_pine.setup({
			variant = "auto",
			dark_variant = "main",
		})
	end
)
