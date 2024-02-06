{
	config, pkgs, lib, system,
	inputs, my-modules,
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
#	imports = [ ../../../modules/home/neovim.nix ];
	security.pam.enableSudoTouchIdAuth = true;
	users.users.nathand = { name = "nathand"; home = "/Users/nathand"; };
	home-manager = {
		useGlobalPkgs = true;
		useUserPackages = true;
		users.nathand = {
#			username = "nathand";
#			homeDirectory = "/Users/nathand";
#			nixpkgs = inputs.pkgs;
			home.stateVersion = "23.11";
			home.file.".hushlogin".text = "";

			programs.neovim.enable = true;
			home.file.neovim = {
				source = ../../../../config/nvim;
				target = ".config/nvim";
			};
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
