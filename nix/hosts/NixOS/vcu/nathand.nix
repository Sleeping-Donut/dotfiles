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
		traceroute
	];
}

