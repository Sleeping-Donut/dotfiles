{
  config,
  pkgs,
  pkgs-unstable,
  nix-modules,
  hostname ? "vm",
  modulesPath,
  inputs,
  disko,
  ...
}:
let
  keys = import nix-modules.keys;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    disko.nixosModules.disko
    ./disko-configuration.nix
    # ./hardware-configuration.nix
  ];

  system.stateVersion = "23.11"; # Did you read the comment?

  nix = {
    gc.automatic = true;
    gc.dates = "weekly";
    gc.options = "--delete-older-than 30d";
    optimise.automatic = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 8;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

  time.timeZone = "GB";

  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  users.users.nathand = {
    isNormalUser = true;
    description = "Nathan";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      keys.LHC
      keys.s24u
    ];
  };

  #	Home Configs
  home-manager = {
    users.nathand = import ./nathand.nix;
  };

  #	System packages
  environment.systemPackages = with pkgs-unstable; [
    git
    fd
    ripgrep
    jq
  ];
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
  };
  services.openssh.enable = true;
}
