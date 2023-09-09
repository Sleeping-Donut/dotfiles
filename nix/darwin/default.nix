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
	system = "x86_64-darwin";							# System architecture (may need to handle different if running x86 and arm machines)

	nix-homebrew-config = {
		# Install homebrew under the default prefix
		enable = true;

		enableRosetta = if system == "aarch64" then true else false;

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
	X68000 = darwin.lib.darwinSystem {					# MacBook12,1 (Early 2015) "Core i5" 2.7Ghz 8GB 2560x1600
		inherit system;
		specialArgs = { inherit user inputs system nix-homebrew nur; hostname = "X68000"; };
		modules = [
			./configuration.nix {						# configs for darwin, home-manager setup networking etc.
				homebrew.brews = defaultBrews ++ [];
				homebrew.casks = defaultCasks ++ [];
				homebrew.masApps = defaultMasApps // {};
			}

			nix-homebrew.darwinModules.nix-homebrew { nix-homebrew = nix-homebrew-config; }

			# Reorganise this so that there are common.nix stuff - want to share things

			home-manager.darwinModules.home-manager {		# Home-Manager module that is used
				home-manager = {
					useGlobalPkgs = true;
					useUserPackages = true;
					extraSpecialArgs = { inherit user; };
					users.${user} = import ./home.nix;
					users.${user}.home.packages = with nixpkgs; [
						bun
					];
				};
			}

		];
	};
}
