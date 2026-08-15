{
  lib,
  config,
  ...
}:
let
  cfg = config.nd0.home.ai-agents;
in
{
  options.nd0.home.ai-agents = {
    enable = lib.mkEnableOption "Setup AI global skill, tool, agents etc.";
  };

  config = lib.mkIf cfg.enable {
    home.file.".agents/AGENTS.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/.agents/AGENTS.md";
    home.file.".agents/skills/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/.agents/skills/";
    home.file.".agents/tools/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/.agents/tools/";
  };
}

