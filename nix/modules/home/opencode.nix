{
  lib,
  config,
  ...
}:
let
  cfg = config.nd0.home.opencode;
in
{
  options.nd0.home.opencode = {
    enable = lib.mkEnableOption "Setup opencode global plugins etc.";
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/opencode/plugins/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/opencode/plugins/";
  };
}

