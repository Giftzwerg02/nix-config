{
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
          $env.config.show_banner = false

          alias "cat" = bat
          alias "find" = fd
          alias "hms" = nh home switch ~/nix-config
          alias "ncs" = nh os switch ~/nix-config
          alias "ssh" = with-env { TERM: linux } { ssh }
          alias "vi" = nvim
          alias "vim" = nvim
          alias "dev" = nix develop --allow-dirty -c $env.SHELL

          def switch [] {
            ncs
            hms
          }

          def cfg [] {
            cd ~/nix-config
            nvim .
          }
        '';

      extraConfig = ''
        $env.config.hooks.command_not_found = source ${pkgs.nix-index}/etc/profile.d/command-not-found.nu
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
