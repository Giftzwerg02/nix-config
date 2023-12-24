{ lib, config, pkgs, ... }:
let
  cfg = config.my-zsh-config;
in
{
  options = {
    my-zsh-config = {
      enable = lib.mkEnableOption "enable zsh config";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      shellAliases = {
        hms = "home-manager switch --flake ~/nix-config";
        ncs = "sudo nixos-rebuild switch --flake ~/nix-config";
        update = "ncs && hms";
        cfg = "cd ~/nix-config && nvim .";
        ls = "eza";
        find = "fd";
        cat = "bat";
        vim = "nvim";
        vi = "nvim";
        cd = "z";
        ssh = "TERM=linux ssh";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "thefuck" ];
        theme = "robbyrussell";
      };
      syntaxHighlighting.enable = true;
      enableAutosuggestions = true;
    };
  };
}
