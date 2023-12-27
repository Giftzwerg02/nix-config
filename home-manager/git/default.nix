{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my-git-config;
in {
  options = {
    my-git-config = {
      enable = lib.mkEnableOption "enable git config";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = "Giftzwerg02";
      userEmail = "chessplayer1@gmx.at";
    };
  };
}
