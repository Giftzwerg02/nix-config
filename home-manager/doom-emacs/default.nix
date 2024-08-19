{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my-doom-emacs-config;
in {
  options = {
    my-doom-emacs-config = {
      enable = lib.mkEnableOption "enable doom-emacs config";
    };
  };

  config = lib.mkIf cfg.enable {
    services.emacs = {
      enable = true;
    };
  };
}
