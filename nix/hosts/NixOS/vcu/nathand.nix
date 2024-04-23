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
		ripgrep
		fd
		bat
		btop
		speedtest-go
	];
}

