#
#  Home-manager configuration for macbook
#
#  flake.nix
#   ├─ ./darwin
#   │   ├─ ./default.nix
#   │   └─ ./home.nix *
#   └─ ./modules
#       └─ ./programs
#           └─ ./alacritty.nix
#

{ pkgs, nur, ... }:

let
	inherit (pkgs.stdenv) isDarwin;# used for firefox - move out?
	shellAliases = {
		ls = "ls --color=auto";
		ll = "ls -laF";
		la = "ls -lah";
		neovim = "nvim";
		nv = "nvim";
		now = "date +\"%T\"";
		nowtime = "now";
		nowdate = "date + \"%d-%m-%Y\"";
	};
in
{
	home = {												# Specific packages for mac
		stateVersion = "22.05";
		packages = with pkgs; [
			# Terminal
			pnpm
		];
		file."hushlogin".text = "";
	};

	programs = {
		zsh = {
			enable = true;
			enableAutosuggestions = true;
			enableSyntaxHighlighting = true;
			history.size = 10000;

			oh-my-zsh = {
				enable = true;
				plugins = [ "git" ];
				theme = "kphoen";
				# custom = "$HOME/.config/zsh_nix/custom";
			};

			shellAliases = shellAliases;

			# initExtras = ........

		};

		tmux = {
			enable = true;
			clock24 = true;
			terminal = "screen-256color";
		};

		fzf = {
			enable = true;
			enableZshIntegration = true;
			enableBashIntegration = true;
		};

		neovim = {
			enable = true;
			viAlias = false;
			vimAlias = false;

			# extra contents fileContents path/to/init.vim
			extraConfig = ''
			set number
			set relativenumber

			set tabstop=4
			set shiftwidth=4
			set noexpandtab

			colorscheme habamax
			'';
		};

		firefox = {
			enable = true;
			package =
				if isDarwin then
					# Handled by Homebrew module
					# Use dummy package to satisfy the requirement
					pkgs.runCommand "firefox-0.0.0" { } "mkdir $out"
				else
					pkgs.firefox;

			profiles = 
				let
					# userChrome = builtins.readFile ../conf.d/userChrome.css;
					extensions = with nur.repos.rycee.firefox-addons; [
						ublock-origin
						multi-account-container
						dark-purple-alexis
						1password-x-password-manager
						dark-nivgvrv
					];
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
					# See how this is used cause i dunno (REF. github:cmacrae/config/bases/home.nix)
					# I don't know how firefox profiles are used... where do you switch after first time?
					home = {
						inherit settings;# extensions;# userChrome;
						id = 0;
					};
				};
		};

	};
}
