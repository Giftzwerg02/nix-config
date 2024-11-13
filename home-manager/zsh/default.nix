{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my-zsh-config;
in {
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
              | ${pkgs.jq}/bin/jq -- -r '. | keys[]' \
              | cut -d \. -f 3- \
              | ${pkgs.fzf}
          '';
      };

      oh-my-zsh = {
        enable = true;
        plugins = ["git" "thefuck"];
        theme = "robbyrussell";
      };

      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;

      initExtra =
        /*
        bash
        */
        ''
          function search_fzf() {
            p=$(fd . . | fzf)
            if [ -d "''${p}" ]; then
              cd "''${p}"
            else
              cd "$(dirname "''${p}")"
            fi
          }

          zle -N search_fzf

          bindkey '^f' search_fzf

          function update() {
            local msg=''${1:-update}

            cd ~/nix-config
            alejandra ./
            git add --all
            git commit -m "''${msg}"
            git push
            sudo nixos-rebuild switch --flake .
            home-manager switch --flake .
          }
        '';
    };
  };
}
