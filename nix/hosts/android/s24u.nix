{
	config, pkgs, lib, system,
	pkgs-unstable, hostname ? "s24u",
	inputs, sources, modules,
	...
}:
{
	system.stateVersion = "24.05";

	time.timeZone = "Europe/London";

	environment.etcBackupExtension = ".bak";
	environment.packages = with pkgs-unstable; [
		curl
		fd
		git
		neovim
		ripgrep
		wget
	];
}
