{
	arch, hostname,
	pkgs, unstable, nur,
	nixModules, nixHomeModules, darwinModules, darwinHomeModules,
	homebrew, homeManager,
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
#	imports = [
#		../../modules/home/neovim.nix
#		homeManager {
##			modules = [ ./home.nix ];
#			home-manager = {
#				users.nathand = import ./nathand.nix { inherit pkgs, unstable, nur };
##				users.nathand = {
##					home.stateVersion = "23.11";
##					home.file.".hushlogin".text = "";
##
##					nd0.neovim = { enable = true; };
##					#nd0.home = {
##					#	neovim.enable = true;
###					#	firefox.enable = true;
##					#};
##				};
##			};
#		}
#	];
}
