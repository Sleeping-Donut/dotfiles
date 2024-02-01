{ pkgs, nur, nixHomeModules, ... }:
{
	imports = [ nixHomeModules.neovim ];

	home.stateVersion = "23.11";
	home.file.".hushlogin".text = "";

	nd0.home = {
		neovim.enable = true;
	};
}
