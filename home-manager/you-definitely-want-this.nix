{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.setup-this-thing;
in {
  imports = [
    ./i3
    ./stylix
    ./git
    ./nushell
    ./zoxide
    ./neovim
    ./dunst
    ./mimeApps
    ./wezterm
    ./niri
    ./firefox
  ];

  options = {
    setup-this-thing = {
      enable = lib.mkEnableOption "enable global stuff config";
      wallpapers-map = lib.mkOption 
      {
          description = "a map from monitor-name to wallpaper-path";
          default = null;
      };
      wallpapers =
        lib.mkOption
        {
          type = with lib.types; listOf (oneOf [str path]);
          description = "provide a list of paths for each wallpaper for each monitor";
          default = ["none"];
        };
      nixosConfigName = lib.mkOption {
        description = "Set this to the nixos-config name of the current machine";
        type = lib.types.str;
        default = null;
      };
      hmConfigName = lib.mkOption {
        description = "Set this to the home-manager-config name of the current machine";
        type = lib.types.str;
        default = null;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    my-i3-config = {
      enable = true;
      wallpapers = cfg.wallpapers;
    };
    my-niri-config = {
      enable = true;
      wallpapers-map = cfg.wallpapers-map;
    };
    my-neovim-config = {
      enable = true;
      nixosConfigName = cfg.nixosConfigName;
      hmConfigName = cfg.hmConfigName;
    };
  };
}
