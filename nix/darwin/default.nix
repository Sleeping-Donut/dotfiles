#
#  These are the different profiles that can be used when building on MacOS
#
#  flake.nix
#   └─ ./darwin
#       ├─ ./default.nix *
#       ├─ configuration.nix
#       └─ home.nix
#

{ lib, inputs, nixpkgs, home-manager, darwin, user, nur, nix-homebrew, ...}:

let
	nix-homebrew-config = {
		# Install homebrew under the default prefix
		enable = true;

		# enableRosetta = system == "aarch64-darwin";

		# User owning homebrew install
		user = user;

		# Automatically migrate existing Homebrew installations
		autoMigrate = true;
	};

	defaultBrews = [];
	defaultCasks = [ "firefox" "1password" ];
	defaultMasApps = { WireGuard = 1451685025; };		# Mac App Store Apps
in
{
	# Find how to split stuff out better from github:cmacrae/config

	X68000 = darwin.lib.darwinSystem {					# MacBook12,1 (Early 2015) "Core i5" 2.7Ghz 8GB 2560x1600
		system = "x86_64-darwin";
		specialArgs = { inherit user inputs nixpkgs nix-homebrew nur; hostname = "X68000"; system = "x86_64-darwin"; };
		modules = [
			./configuration.nix {						# configs for darwin, home-manager setup networking etc.
				homebrew.brews = [ ];
				homebrew.casks = [ "firefox" "1password" ];
				homebrew.masApps = { WireGuard = 1451685025; };
			}

			nix-homebrew.darwinModules.nix-homebrew { nix-homebrew = nix-homebrew-config // { enableRosetta = true; }; }

			# Reorganise this so that there are common.nix stuff - want to share things

			home-manager.darwinModules.home-manager {		# Home-Manager module that is used
				home-manager = {
					useGlobalPkgs = true;
					useUserPackages = true;
					extraSpecialArgs = { inherit user nixpkgs; extra-packages =  [];};# nixpkgs.bun]; };
					users.${user} = import ./home.nix { inherit nur;};# pkgs; extra-packages = with nixpkgs; [ bun ] ;};
				};
			}

		];
	};
	
	LHC = darwin.lib.darwinSystem {					# Mac details go here
		system = "aarch64-darwin";
		specialArgs = { inherit user inputs nixpkgs nix-homebrew nur; hostname = "LHC"; system = "aarch64-darwin"; };
		modules = [
			./configuration.nix {						# configs for darwin, home-manager setup networking etc.
				homebrew.brews = [ ];
				homebrew.casks = [ "firefox" "1password" ];
				homebrew.masApps = { WireGuard = 1451685025; };
			}

			nix-homebrew.darwinModules.nix-homebrew { nix-homebrew = nix-homebrew-config // { enableRosetta = true; }; }

			# Reorganise this so that there are common.nix stuff - want to share things

			home-manager.darwinModules.home-manager {		# Home-Manager module that is used
				home-manager = {
					useGlobalPkgs = true;
					useUserPackages = true;
					extraSpecialArgs = { inherit user nixpkgs nur; extra-packages =  [];};# nixpkgs.bun]; };
					users.${user} = import ./home.nix; #{ inherit nur pkgs; extra-packages = with nixpkgs; [ bun ] ;};
				};
			}

		];
	};
}
