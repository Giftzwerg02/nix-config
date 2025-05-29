{
  lib,
  config,
  pkgs,
  ...
}: {
  programs = {
    nushell = {
      enable = true;
      configFile.text =
        /*
        nu
        */
        ''
          alias "cat" = bat
          alias "find" = fd
          alias "hms" = nh home switch ~/nix-config
          alias "ncs" = nh os switch ~/nix-config
          alias "ssh" = with-env { TERM: linux } { ssh }
          alias "vi" = nvim
          alias "vim" = nvim
          alias "dev" = nix develop -c $env.SHELL --allow-dirty

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
