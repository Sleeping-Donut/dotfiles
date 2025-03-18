{
	lib, config, pkgs,
	pkgs-unstable,
	...
}:
let
in
{
	home.stateVersion = "23.11";

	home.packages = with pkgs-unstable; [
		ripgrep
		bat
		btop
		speedtest-go
		systemctl-tui
		traceroute
	];
}

