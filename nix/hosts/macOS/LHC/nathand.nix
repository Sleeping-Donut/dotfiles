{
  config,
  pkgs,
  lib,
  system,
  pkgs-unstable,
  inputs,
  sources,
  modules,
  ...
}:
let
  neovim-nightly = import sources.overrides.neovim { inherit inputs system; };
in
{
  imports = [
    inputs.nur.modules.homeManager.default

    modules.home.firefox
    modules.home.neovim
    modules.home.zsh
    modules.home.shell-profile
    modules.home.tealdeer
    modules.home.tmux
    modules.home.ata-conf
    modules.home.bins

    modules.darwin-home.alacritty-conf
  ];

  home.stateVersion = "26.05";
  home.file.".hushlogin".text = "";

  # TODO: Need to copy .profile-prefs to $HOME
  # NOTE: only copy if file does not exists

  home.packages = with pkgs-unstable; [
    # gobang
    # termscp
    # twitch-tui
    age
    ansible
    bottom
    btop
    chatgpt-cli
    comma # prefix comand with , to use nix run w/ an autosearch
    ctop
    dua
    dust
    fastfetch
    fd
    gallery-dl
    gifski
    glow
    httpie
    hydra-check
    jdk
    lazygit
    magic-wormhole
    nh
    nix-output-monitor
    nix-search-cli
    scrcpy
    speedtest-go
    speedtest-rs
    starship
    stow
    tailscale
    tokei
    tinymist
    typst
    tz # timezone tool
    yq # jq for YAML
  ];

  nd0.home = {
    alacritty-conf.enable = true;
    ata-conf.enable = true;
    bins.enable = true;
    # firefox.enable = true;
    neovim = {
      enable = true;
    };
    shell-profile = {
      enable = true;
      symlink.enable = true;
    };
    tealdeer.enable = true;
    tmux.enable = true;
    zsh.enable = true;
  };

  programs = {
    bat.enable = true;
    direnv = {
      package = pkgs-unstable.direnv;
      enable = true;
      enableZshIntegration = true;
    };
    eza = {
      enable = true;
      package = pkgs-unstable.eza;
    };
    fzf = {
      enable = true;
      package = pkgs-unstable.fzf;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    gh = {
      enable = true;
      package = pkgs-unstable.gh;
      settings = {
        editor = "nvim";
        git_protocol = "ssh";
      };
    };
    git.enable = true;
    neovim.package = neovim-nightly;
    jq = {
      enable = true;
      package = pkgs-unstable.jq;
    };
    ripgrep = {
      enable = true;
      package = pkgs-unstable.ripgrep;
    };
    yt-dlp = {
      enable = true;
      package = pkgs-unstable.yt-dlp;
    };
    zellij = {
      enable = true;
      package = pkgs-unstable.zellij;
    };
  };
}
