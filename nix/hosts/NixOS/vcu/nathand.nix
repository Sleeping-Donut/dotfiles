{
	lib, config, pkgs,
	pkgs-unstable,
	...
}:
let
in
{
#	Indicate real user
#	- set group to "users"
#	- create and set home to match username
#	- uses default shell
	isNormalUser = true;
	description = "Nathan";
	extraGroups = [ "wheel" "networkmanager" "labemembers" ];
	openssh.authorizedKeys.keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2rAuYj5hGLj6eFScSjJoz5XXZzTiQVPWdL+fWUtp9q" # LHC
	];
}

