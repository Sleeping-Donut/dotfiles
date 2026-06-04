{
  lib,
  pkgs,
  pkgs-unstable,
  config,
  ...
}:
let
  cfg = config.nd0.home.neovim;
in
{
  options.nd0.home.neovim = {
    enable = lib.mkEnableOption "Whether to install neovim in home";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
    };
    home.file.".config/nvim/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/nvim/";
  };
}
