{ pkgs, nur, home-modules, ... }:
{
	imports = [ ./testfile.nix ./neovim.nix ];#home-modules.neovim ];

	home.stateVersion = "23.11";
	home.file.".hushlogin".text = "";
#	home.file."printresult.txt".text = "${./testfile.nix}";

	nd0.home = {
#		neovim.enable = true;
		testfile = { enable = true; text = "give a go"; };		
	};
}
