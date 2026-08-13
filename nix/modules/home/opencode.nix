{
  lib,
  config,
  ...
}:
let
  cfg = config.nd0.home.neovim;
in
{
  options.nd0.home.opencode = {
    enable = lib.mkEnableOption "Setup opencode global skill, tool, agents etc.";
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/opencode/AGENTS.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/opencode/AGENTS.md";
    home.file.".config/opencode/skills/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/opencode/skills/";
    home.file.".config/opencode/tools/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/opencode/tools/";
  };
}

