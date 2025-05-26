{
  lib,
  config,
  pkgs,
  ...
}: {
  programs = {
    nushell = {
      enable = true;
      configFile.source = ./config.nu;
      shellAliases = {
        hms = "nh home switch ~/nix-config";
        ncs = "nh os switch ~/nix-config";
        switch = "ncs; hms";
        cfg = "cd ~/nix-config; nvim .";
        ls = "eza";
        find = "fd";
        cat = "bat";
        vim = "nvim";
        vi = "nvim";
        cd = "z";
        ssh = "with-env { TERM: linux } { ssh }";
      };

      extraConfig = /* nu */ ''
      def switch [] {
        ncs
        hms
      }

      def cfg [] {
        cd ~/nix-config
        nvim .
      }
      '';
    };

    starship = {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };

    carapace.enable = true;
    carapace.enableNushellIntegration = true;
  };
}
