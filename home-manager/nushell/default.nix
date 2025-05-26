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
      extraConfig =
        /*
        nu
        */
        ''
          alias "cat" = bat
          alias "cd" = z
          alias "find" = fd
          alias "hms" = nh home switch ~/nix-config
          alias "ls" = eza
          alias "ncs" = nh os switch ~/nix-config
          alias "ssh" = with-env { TERM: linux } { ssh }
          alias "vi" = nvim
          alias "vim" = nvim

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
