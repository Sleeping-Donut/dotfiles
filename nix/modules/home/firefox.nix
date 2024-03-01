{ lib, pkgs, pkgs-unstable, pkgs-nur, system, config, ... }:
with lib;
let
	cfg = config.nd0.home.firefox;
in {
	options.nd0.home.firefox = with types; {
		enable = mkEnableOption "Whether to load firefox configs";
		useUnstable = mkEnableOption "Whether to use unstable pkgs";
		extensions.enable = mkEnableOption "Whether to enable installing extensions";
	};

	config = mkIf cfg.enable {
		programs.firefox = {
			enable = true;
			package =
				if system == "aarch64-darwin" || system == "x68_64_darwin" then
					# Handled by Homebrew module
					# Use dummy package to satisfy the requirement
					pkgs.runCommand "firefox-0.0.0" { } "mkdir $out"
				else
					if cfg.useUnstable then
						pkgs-unstable.firefox
					else
						pkgs.firefox;

			profiles =
				let
					# userChrome = builtins.readFile ../conf.d/userChrome.css;
					# extensions = with nur.repos.rycee.firefox-addons; [
					# 	ublock-origin
					# 	multi-account-container
					# 	dark-purple-alexis
					# 	1password-x-password-manager
					# 	dark-nivgvrv
					# ];
					search = {
						default = "DuckDuckGo";
						order = [ "DuckDuckGo" "Google" "Nix Packages" ];
						engines = {
							# Custom search engines
							"Bing".metadata.hidden = true;
							"Google".metadata.alias = "@g"; # Only 1 alias for builtins
							"Nix Packages" = {
								# icon = "";
								definedAliases = [ "@np" ];
								urls = [{
									template = "";
									params = [
										{ name = "type"; value = "packages"; }
										{ name = "query"; value = "{searchTerms}"; }
									];
								}];
							};
						};
					};
					settings = {
						"app.update.auto" = true;
						"browser.bookmarks.showMobileBookmarks" = true;
						"browser.ctrlTab.recentlyUsedOrder" = false;
						"browser.download.useDownloadDir" = false;
						"browser.newtabpage.activity-stream.discoverystream.saveToPocketCard.enabled" = false;
						"browser.newtabpage.activity-stream.discoverystream.sendToPocket.enabled" = false;
						"browser.newtabpage.activity-stream.feeds.section.topstories" = false;
						"browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
						"browser.newtabpage.activity-stream.showSponsored" = false;
						"browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
						"browser.newtabpage.enabled" = true;
						"browser.search.countryCode" = "GB";
						"browser.search.isUS" = false;
						"browser.search.region" = "GB";
						"browser.startup.homepage" = "about:home";
						"browser.toolbars.bookmarks.visibility" = "always";
						"browser.uidensity" = 1;
						"browser.urlbar.placeholderName" = "DuckDuckGo";
						"browser.urlbar.suggest.pocket" = false;
						"browser.urlbar.update1" = true;
						"distribution.searchplugins.defaultLocale" = "en-GB";
						"extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
						"extensions.pocket.bffRecentSaves" = false;
						"extensions.pocket.enabled" = false;
						"extensions.pocket.showHome" = false;
						"general.useragent.locale" = "en-GB";
						"privacy.trackingprotection.enabled" = true;
						"privacy.trackingprotection.socialtracking.annotate.enabled" = true;
						"privacy.trackingprotection.socialtracking.enabled" = true;
						"reader.color_scheme" = "auto";
						"services.sync.declinedEngines" = "addons,passwords,prefs";
						"services.sync.engine.addons" = false;
						"services.sync.engine.passwords" = false;
						"services.sync.engine.prefs" = false;
						"services.sync.engineStatusChanged.addons" = true;
						"services.sync.engineStatusChanged.prefs" = true;
						"services.sync.prefs.sync.browser.download.useDownloadDir" = false;
						"services.sync.prefs.sync.browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
						"services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsored" = false;
						"services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
						"signon.rememberSignons" = false;
						# "identity.fxaccounts.account.device.name" = config.networking.hostName;
					};
				in
				{
					default = let
						settings-merged = settings // { force = true; };
					in {
						id = 0;
						name = "home";
						isDefault = true;
						settings = settings-merged;
						search = {
							force = true;
							default = "DuckDuckGo";
							order = [ "DuckDuckGo" "Google" ];
						};
						# extensions = with pkgs.nur.repos.rycee.firefox-addons; mkIf cfg.extensions.enable [
						# 	ublock-origin
						# 	multi-account-container
						# 	dark-purple-alexis
						# 	1password-x-password-manager
						# 	dark-nivgvrv
						# ];
					};
					# See how this is used cause i dunno (REF. github:cmacrae/config/bases/home.nix)
					# I don't know how firefox profiles are used... where do you switch after first time?
					# home = {
					# 	inherit settings;# extensions;# userChrome;
					# 	id = 1;
					# };
				};
		};
	};
}
