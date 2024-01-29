{ options, config, lib, pkgs, ... }:
with lib;
let
	cfg = config.nd0.home.firefox-home;
in {
	options.nd0.home.firefox-home = with types; {
		enable = mkEnableOption "Whether to load firefox configs";
		isDarwin = mkBoolOpt false "Whether to use the linux package or dummy placeholder";
	};

	config = mkIf cfg.Enable {
		programs.firefox = {
			enable = true;
			package =
				if cfg.isDarwin then
					# Handled by Homebrew module
					# Use dummy package to satisfy the requirement
					pkgs.runCommand "firefox-0.0.0" { } "mkdir $out"
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
						"browser.startup.homepage" = "about:home";
						"browser.search.region" = "GB";
						"browser.search.countryCode" = "GB";
						"browser.search.isUS" = false;
						"browser.ctrlTab.recentlyUsedOrder" = false;
						"browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
						"browser.newtabpage.activity-stream.showSponsored" = false;
						"browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
						"browser.newtabpage.activity-stream.discoverystream.saveToPocketCard.enabled" = false;
						"browser.newtabpage.activity-stream.feeds.section.topstories" = false;
						"extensions.pocket.bffRecentSaves" = false;
						"browser.newtabpage.activity-stream.discoverystream.sendToPocket.enabled" = false;
						"browser.urlbar.suggest.pocket" = false;
						"browser.newtabpage.enabled" = true;
						"browser.bookmarks.showMobileBookmarks" = true;
						"browser.toolbars.bookmarks.visibility" = "always";
						"browser.uidensity" = 1;
						"browser.urlbar.placeholderName" = "DuckDuckGo";
						"browser.urlbar.update1" = true;
						"distribution.searchplugins.defaultLocale" = "en-GB";
						"extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
						"extensions.pocket.enabled" = false;
						"extensions.pocket.showHome" = false;
						"general.useragent.locale" = "en-GB";
						# "identity.fxaccounts.account.device.name" = config.networking.hostName;
						"privacy.trackingprotection.enabled" = true;
						"privacy.trackingprotection.socialtracking.enabled" = true;
						"privacy.trackingprotection.socialtracking.annotate.enabled" = true;
						"reader.color_scheme" = "auto";
						"services.sync.declinedEngines" = "addons,passwords,prefs";
						"services.sync.engine.addons" = false;
						"services.sync.engineStatusChanged.addons" = true;
						"services.sync.engine.passwords" = false;
						"services.sync.engine.prefs" = false;
						"services.sync.engineStatusChanged.prefs" = true;
						"services.sync.prefs.sync.browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
						"services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsored" = false;
						"services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
						"signon.rememberSignons" = false;
					};
				in
				{
					default = {
						id = 0;
						name = "home";
						isDefault = true;
						inherit search settings;
						search = {
							default = "DuckDuckGo";
							order = [ "DuckDuckGo" "Google" ];
						};
					};
					# See how this is used cause i dunno (REF. github:cmacrae/config/bases/home.nix)
					# I don't know how firefox profiles are used... where do you switch after first time?
					home = {
						inherit settings;# extensions;# userChrome;
						id = 1;
					};
				};
		};
	};
}
