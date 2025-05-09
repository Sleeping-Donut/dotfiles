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

	home.packages = with pkgs-unstable; [
		bat
		btop
		ripgrep
		speedtest-go
		systemctl-tui
		traceroute
	];
}

