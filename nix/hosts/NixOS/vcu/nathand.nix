{
	pkgs,
	pkgs-unstable,
	...
}:
let
in
{
	home.stateVersion = "23.11";

	home.packages = with pkgs-unstable; [
		bat
		btop
		ripgrep
		speedtest-go
		systemctl-tui
		traceroute
	];
}

