{ pkgs, nur, nixHomeModules, ... }:
{
	imports = [ ../../../modules/home/neovim.nix ];

	home.stateVersion = "23.11";
	home.file.".hushlogin".text = "";

	nd0.home = {
		neovim.enable = true;
	};
}
