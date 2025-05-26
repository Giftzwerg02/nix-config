{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my-zoxide-config;
in {
  options = {
    my-zoxide-config = {
      enable = lib.mkEnableOption "enable zoxide config";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
