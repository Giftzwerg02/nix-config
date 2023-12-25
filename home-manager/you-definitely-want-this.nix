{ lib, config, pkgs, ... }:
let
  cfg = config.setup-this-thing;
in
{
  imports = [
    ./i3
    ./stylix
    ./git
    ./kitty
    ./carapace
    ./zsh
    ./zoxide
    ./doom-emacs
    ./neovim
    ./dunst
    ./mimeApps
  ];

  options = {
    setup-this-thing = {
      enable = lib.mkEnableOption "enable global stuff config";
      wallpapers = lib.mkOption
        {
          type = with lib.types; listOf (oneOf [ str path ]);
          description = "provide a list of paths for each wallpaper for each monitor";
          default = [ "none" ];
        };

    };
  };

  config = lib.mkIf cfg.enable {
    my-stylix-config.enable = true;
    my-git-config.enable = true;
    my-kitty-config.enable = true;
    my-i3-config =
      {
        enable = true;
        wallpapers = cfg.wallpapers;
      };  
    my-carapace-config.enable = true;
    my-zsh-config.enable = true;
    my-zoxide-config.enable = true;
    my-doom-emacs-config.enable = false;
    my-neovim-config.enable = true;
    my-dunst-config.enable = true;
    my-mimeApps-config.enable = true;
  };
}
