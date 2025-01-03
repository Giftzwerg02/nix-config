{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my-fish-config;
in {
  options = {
    my-fish-config = {
      enable = lib.mkEnableOption "enable fish config";
    };
  };
  config = lib.mkIf cfg.enable {
    programs = {
      thefuck.enableFishIntegration = true;
      fzf.enableFishIntegration = true;
      eza.enableFishIntegration = true;
    };

    programs.fish = {
      enable = true;
      shellAliases = {
        hms = "home-manager switch --flake ~/nix-config";
        ncs = "sudo nixos-rebuild switch --flake ~/nix-config";
        switch = "ncs && hms";
        cfg = "cd ~/nix-config && nvim .";
        ls = "eza";
        find = "fd";
        cat = "bat";
        vim = "nvim";
        vi = "nvim";
        cd = "z";
        ssh = "TERM=linux ssh";
        search =
          /*
          bash
          */
          ''
            nix search nixpkgs --json ^ \
              | ${pkgs.jq}/bin/jq -r ". | keys[]" \
              | cut -d \. -f 3- \
              | ${pkgs.fzf}/bin/fzf
          '';
      };

      functions = {
        update =
          /*
          fish
          */
          ''
            set msg $argv[1] || 'update'

            cd ~/nix-config
            alejandra ./
            git add --all
            git commit -m "$msg"
            git push
            sudo nixos-rebuild switch --flake .
            home-manager switch --flake .
          '';
      };
    };
  };
}
