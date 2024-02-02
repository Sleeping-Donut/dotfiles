inputs @ {
#	arch, hostname, pkgs, unstable, nur,
#	nixModules, nixHomeModules, homeManagerM,
#	darwinModules, darwinHomeModules, homebrewM,
#	npkgs,
	...
}:
let
#	homeModules = nixHomeModules { inherit pkgs; };
#	neovimConfig = homeModules.neovim;
#	generateUserHome = (username:
#		users."${username}" = import (./ + username) { inherit pkgs, unstable, nur, nixHomeModules, darwinHomeModules ;};
#	);
in
{
#	users.users.nathand = { name = "nathand"; home = "/Users/nathand"; };
	home-manager = {
		users.nathand = {
			username = "nathand";
			homeDirectory = "/Users/nathand";
			nixpkgs = npkgs;
			home.stateVersion = "23.11";
			home.file.".hushlogin".text = "";
		};
	};
#	modules = [
#	];
##		../../../modules/home/neovim.nix
##		home-manager {
##			modules = [ ];#../../../modules/home/neovim.nix ];
#			home-manager = {
##				users.nathand = import ./nathand.nix { inherit pkgs, unstable, nur };
#				users.nathand = {
#					home.stateVersion = "23.11";
#					home.file.".hushlogin".text = "";
##
#					nd0.neovim = { enable = true; };
##					#nd0.home = {
##					#	neovim.enable = true;
###					#	firefox.enable = true;
##					#};
#				};
#			};
##		}
}
