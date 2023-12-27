{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my-carapace-config;
in {
  options = {
    my-carapace-config = {
      enable = lib.mkEnableOption "enable carapace config";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.carapace = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
