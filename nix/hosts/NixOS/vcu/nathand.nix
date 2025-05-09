{
	pkgs,
	pkgs-unstable,
	repo-root,
	...
}:
{
	home.stateVersion = "23.11";

	home.file.".profile".text = ''
		export PATH="$PATH:$HOME/.local/bin"
	'';
	home.file.".local/bin/softreboot" = {
		source = repo-root + /nix/scripts/softreboot.sh;
		executable = true;
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

