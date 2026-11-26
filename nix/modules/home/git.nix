{
  lib,
  config,
  repo-root,
  ...
}:
let
  cfg = config.nd0.home.git;
in
{
  options.nd0.home.git = {
    enable = lib.mkEnableOption "Apply my default git config";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      includes = [
        { path = "${repo-root}/config/git/config"; }
      ];
    };
  };
}

