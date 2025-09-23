{
	lib, config, pkgs,
	pkgs-unstable,
	repo-root,
	...
}:
{
	home.stateVersion = "23.11";

	home.file.".profile".text = ''
		export PATH="$PATH:$HOME/.local/bin"
	'';
	home.file.".local/bin/bgrebuild" = let
		bgrebuild-script = pkgs.writeShellScript "bgrebuild" ''
			#!${pkgs.stdenv.shell}

			tmux_cmd="${pkgs.lib.getExe pkgs.tmux}"
			watch_cmd="${pkgs.lib.getExe pkgs.watch}"
			nom_cmd="${pkgs.lib.getExe pkgs.nix-output-monitor}"

			if $tmux_cmd has-session -t nixos-rebuild 2>/dev/null; then
				echo "Attaching to existing 'nixos-rebuild' session..."
				$tmux_cmd attach-session -t nixos-rebuild
				echo "Error: a 'nixos-rebuild' session already exists. Use 'tmux attach -t nixos-rebuild' to view it" >&2
				exit 1
			fi

			# Use the provided argument as the flake path, or Error
			flake_path="$${1:?Error: A flake path is required}"

			echo "Starting a new 'nixos-rebuild' session..."
			sudo $tmux_cmd new-session -d -s nixos-rebuild "$nom_cmd nixos-rebuild switch --flake $flake_path"

			# Watch the output with color and capture scrollback
			$watch_cmd -c "$tmux_cmd capture-pane -t nixos-build -pS-"
		'';
	in {
		executable = true;
		source = bgrebuild-script;
	};

	home.packages = with pkgs-unstable; [
		bat
		btop
		ripgrep
		speedtest-go
		systemctl-tui
		traceroute
	];
}

