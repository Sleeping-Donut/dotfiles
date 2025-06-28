#!/usr/bin/env bash

# jq is a hard dependency for this
command -v jq >/dev/null 2>&1 || { echo "Error: jq is not installed. Please install it."; exit 1; }

get_icons() {
	local name="$1"
	local icon=""

	# Map names to icons
	case "$name" in
		firefox|Firefox|'Mozilla Firefox'|org.mozilla.firefox) icon="" ;;
		chromium|Chromium|'Google Chrome'|google-chrome) icon="" ;;
		Brave|brave-browser) icon="" ;;
		Vivaldi|vivaldi-stable) icon="" ;;
		microsoft-edge|'Microsoft Edge'|microsoft-edge-dev|microsoft-edge-beta) icon="" ;;
		zenbrowser|'Zen Browser') icon="" ;;

		Alacritty|alacritty) icon="" ;;
		kitty) icon="" ;;
		gnome-terminal|Gnome-terminal|io.elementary.terminal) icon="" ;;
		foot) icon="" ;;

		code|Code|VSCodium|VSCodium-wayland) icon="" ;;

		nautilus|Nautilus) icon="" ;;

		mpv|Mpv) icon="" ;;
		vlc|Vlc) icon="" ;;
		pavucontrol|Pavucontrol) icon="" ;;

		telegram-desktop|Telegram|TelegramDesktop) icon="" ;;
		discord|Discord) icon="" ;;

		gimp|Gimp) icon="" ;;
		blender|Blender) icon="" ;;
		obs|Obs|obs-studio) icon="" ;;
		steam|Steam|SteamRuntime) icon="" ;;
		libreoffice|Libreoffice) icon="" ;;

		*) icon="" ;;
	esac
	echo "$icon"
}

# Get current workspace windows
current_workspace_windows=$(swaymsg -t get_tree | jq -r ' .
	| .nodes[] | recurse(.nodes[], .floating_nodes[])
	| select(.type=="workspace" and .focused).nodes[]
	| recurse(.nodes[], .floating_nodes[])
	| select(.type=="con" or .type=="floating_con")
	| (.app_id // .window_properties.class // .name)
')

echo "$current_workspace_windows"
all_window_icons=""
if [ -n "$current_workspace_windows" ]; then
	while IFS= read -r line; do
		all_window_icons+=$(get_icon "$line")
		all_window_icons+=" " # Add a space between icons
	done <<< "$current_workspace_windows"
	all_window_icons="${all_window_icons%" "}" # Remove trailing space
fi

# Output JSON for Waybar
# The 'text' field will be displayed by the custom module
echo "{\"text\": \"$all_window_icons\"}"

