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
    ./kitty
    ./carapace
    ./zsh
    ./zoxide
    ./neovim
    ./dunst
    ./mimeApps
  ];

  options = {
    setup-this-thing = {
      enable = lib.mkEnableOption "enable global stuff config";
      wallpapers =
        lib.mkOption
        {
          type = with lib.types; listOf (oneOf [str path]);
          description = "provide a list of paths for each wallpaper for each monitor";
          default = ["none"];
        };
      nixosConfigName = lib.mkOption {
        description = "Set this to the nixos-config name of the current machine";
        type = lib.types.string;
        default = null;
      };
      hmConfigName = lib.mkOption {
        description = "Set this to the home-manager-config name of the current machine";
        type = lib.types.string;
        default = null;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    my-stylix-config.enable = true;
    my-git-config.enable = true;
    my-kitty-config.enable = true;
    my-i3-config = {
      enable = true;
      wallpapers = cfg.wallpapers;
    };
    my-carapace-config.enable = true;
    my-zsh-config.enable = true;
    my-zoxide-config.enable = true;
    my-neovim-config = {
      enable = true;
      nixosConfigName = cfg.nixosConfigName;
      hmConfigName = cfg.hmConfigName;
    };
    my-dunst-config.enable = true;
    my-mimeApps-config.enable = true;
  };
}
