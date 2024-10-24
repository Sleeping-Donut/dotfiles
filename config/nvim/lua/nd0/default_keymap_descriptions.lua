--- Default keymap descriptions so I can search for keymaps w/out needing to
--- pull up docs

---@alias VimMode '"n"' | '"i"' | '"v"' | '"V"' | '"<C-v>"' | '"x"' | '"s"' | '"o"' | '"c"' | '"t"' | '"!"'

--- Maps a key with a description for given modes.
--- @param map string: The keymap to set.
--- @param description string: The description of the keymap.
--- @param modes VimMode | VimMode[] | nil: A list of modes (e.g., "n", "v"). If nil, defaults to normal mode ("n").
local function desc_map(map, description, modes)
	if modes == nil then modes = "n" end
	-- keymap prefixed by <Plug> to make mapping virtual so can only invoke in C mode
	vim.keymap.set(
		modes,
		"<Plug>"..map,
		":lua print(\""..description.."\")<CR>",
		{ desc = description }
	)
end

desc_map("§n>", "Indent by n", "x")
desc_map(">>", "Indent line")
desc_map("§n<", "Unindent by n", "x")
desc_map("<<", "Unindent line")
desc_map("~", "Switch case")
desc_map("C-a", "Increment number")
desc_map("C-x", "Decrement number")

