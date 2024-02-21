{ pkgs, nur, ... }:
{
	imports = [ ];#./testfile.nix ];

	home.stateVersion = "23.11";
	home.file.".hushlogin".text = "";
	home.file."printresult.txt".text = "${./testfile.nix}";

#	nd0.home = {
#		testfile = { enable = true; text = "give a go"; };		
#	};
}
