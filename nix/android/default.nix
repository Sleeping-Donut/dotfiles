#
#  These are the different profiles that can be used when building on MacOS
#
#  flake.nix
#   └─ ./darwin
#       ├─ ./default.nix *
#       ├─ configuration.nix
#       └─ home.nix
#

{ lib, inputs, nixpkgs, home-manager, nix-on-droid, user, ...}:

{
	# Reference github:t184256/nix-on-droid flake.nix for how it can be setup nicely

	# NOP6 = nix-on-droid.lib.nixOnDroidConfuguration {				# OnePlus6 .......
	# 	specialArgs = { inherit user inputs; hostname = "NOP6"; };
	# 	modules = [
	# 		./configuration.nix										# configs for nix-on-droid, home-manager setup networking etc.

	# 		# Reorganise this so that there are common.nix stuff - want to share things

	# 		home-manager.darwinModules.home-manager {				# Home-Manager module that is used
	# 			home-manager = {
	# 				useGlobalPkgs = true;
	# 				useUserPackages = true;
	# 				extraSpecialArgs = { inherit user; };
	# 				users.${user} = import ./home.nix;
	# 			};
	# 		}
	# 	];
	# };
}
