{ pkgs, lib, config, ... }:
let
	cfg = config.nd0.plex-version-override;
in
{
	# Run `nix/scripts/getPkgHash.sh 'plex' '<VERSION>' to find hash
	options.nd0.plex-version-override = {
		version = lib.mkOption {
			type = lib.types.str;
			default = "";
		};
		hash = lib.mkOption {
			type = lib.types.str;
		};
	};

	config = lib.mkIf (cfg.version != "") {
		services.plex.package = pkgs.plex.overrideAttrs (_: rec {
			version = cfg.version;
			src = pkgs.fetchurl {
				url = "https://downloads.plex.tv/plex-media-server-new/${cfg.version}/debian/plexmediaserver_${cfg.version}_amd64.deb";
				sha256 = cfg.hash;
			};
		});
	};
}

