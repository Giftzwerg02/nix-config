# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  imports = [
    inputs.nix-doom-emacs.hmModule
    ../my-i3.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      inputs.neovim-nightly-overlay.overlays.default
    ];
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  stylix.image = pkgs.fetchurl {
    url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
    sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
  };
  stylix = {
    polarity = "dark";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    cursor = {
      name = "capitaine-cursors";
      package = pkgs.capitaine-cursors;
      size = 40;
    };
    fonts = {
      sizes = {
        applications = 12;
        desktop = 12;
        popups = 8;
      };

    };
  };

  home.username = "benjamin";
  home.homeDirectory = "/home/benjamin";

  programs.git = {
    enable = true;
    userName = "Giftzwerg02";
    userEmail = "chessplayer1@gmx.at";
  };

  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
    };
    shellIntegration = {
      enableZshIntegration = true;
    };
  };


  my-i3-config.enable = false;

  xsession.windowManager.i3 =
    let
      modifier = "Mod4";
      refresh_i3status = "killall -SIGUSR1 i3status";
      ws1 = "1";
      ws2 = "2";
      ws3 = "3";
      ws4 = "4";
      ws5 = "5";
      ws6 = "6";
      ws7 = "7";
      ws8 = "8";
      ws9 = "9";
      ws10 = "10";
    in
    {
      enable = false;
      config = {
        modifier = "${modifier}"; 

        # fonts = [ "pango:fira 7" ];

        startup = [
          { command = "i3"; }
          { command = "i3lock --nofork"; }
          { command = "nm-applet"; }
          { command = "feh --bg-fill pictures/wallpapers/middle.jpg --bg-fill pictures/wallpapers/left.jpg  --bg-fill pictures/wallpapers/right.jpg"; }
          { command = "flameshot"; }
        ];

        keybindings = {
          "XF86AudioRaiseVolume" = "exec --no-startup-id pamixer --increase 5 && ${refresh_i3status}";
          "XF86AudioLowerVolume" = "exec --no-startup-id pamixer --decrease 5 && ${refresh_i3status}";
          "XF86AudioMute" = "exec --no-startup-id pamixer --togle-mute && ${refresh_i3status}";

          "${modifier}+Control+d" = "exec dunstctl action";

          "${modifier}+Return" = "exec kitty";

          "${modifier}+Shift+q" = "kill";

          "${modifier}+p" = "exec \"rofi -show drun -show-icons\"";

          # toggle nightlight (redshift)
          "${modifier}+Shift+a" = "exec \"toggle-redshift\"";

          # screenshot
          "${modifier}+Shift+s" = "exec \"flameshot gui\"";

          # lock
          "${modifier}+Control+l" = "exec \"i3lock --color 181926\"";

          # change focus
          "${modifier}+j" = "focus left";
          "${modifier}+k" = "focus down";
          "${modifier}+l" = "focus up";
          "${modifier}+odiaeresis" = "focus right";

          # alternatively, you can use the cursor keys:
          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";

          # move focused window
          "${modifier}+Shift+j" = "move left";
          "${modifier}+Shift+k" = "move down";
          "${modifier}+Shift+l" = "move up";
          "${modifier}+Shift+h" = "move right";

          # alternatively, you can use the cursor keys:
          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";

          # split in horizontal orientation
          "${modifier}+h" = "split h";

          # split in vertical orientation
          "${modifier}+v" = "split v";

          # enter fullscreen mode for the focused container
          "${modifier}+f" = "fullscreen toggle";

          # change container layout (stacked, tabbed, toggle split)
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";

          # toggle tiling / floating
          "${modifier}+Shift+space" = "floating toggle";

          # change focus between tiling / floating windows
          "${modifier}+space" = "focus mode_toggle";

          # focus the parent container
          "${modifier}+a" = "focus parent";


          # switch to workspace
          "${modifier}+1" = "workspace number ${ws1}";
          "${modifier}+2" = "workspace number ${ws2}";
          "${modifier}+3" = "workspace number ${ws3}";
          "${modifier}+4" = "workspace number ${ws4}";
          "${modifier}+5" = "workspace number ${ws5}";
          "${modifier}+6" = "workspace number ${ws6}";
          "${modifier}+7" = "workspace number ${ws7}";
          "${modifier}+8" = "workspace number ${ws8}";
          "${modifier}+9" = "workspace number ${ws9}";
          "${modifier}+0" = "workspace number ${ws10}";

          # move container to ws
          "${modifier}+Shift+1" = "move container to workspace number ${ws1}";
          "${modifier}+Shift+2" = "move container to workspace number ${ws2}";
          "${modifier}+Shift+3" = "move container to workspace number ${ws3}";
          "${modifier}+Shift+4" = "move container to workspace number ${ws4}";
          "${modifier}+Shift+5" = "move container to workspace number ${ws5}";
          "${modifier}+Shift+6" = "move container to workspace number ${ws6}";
          "${modifier}+Shift+7" = "move container to workspace number ${ws7}";
          "${modifier}+Shift+8" = "move container to workspace number ${ws8}";
          "${modifier}+Shift+9" = "move container to workspace number ${ws9}";
          "${modifier}+Shift+0" = "move container to workspace number ${ws10}";

          # reload config
          "${modifier}+Shift+c" = "reload";

          # restart i3
          "${modifier}+Shift+r" = "restart";

          "${modifier}+r" = "mode \"resize\"";

        };

        modes = {
          resize = {
            "j" = "resize shrink width 10 px or 10 ppt";
            "k" = "resize grow height 10 px or 10 ppt";
            "l" = "resize shrink height 10 px or 10 ppt";
            "h" = "resize grow width 10 px or 10 ppt";

            # same bindings, but for the arrow keys
            "Left" = "resize shrink width 10 px or 10 ppt";
            "Down" = "resize grow height 10 px or 10 ppt";
            "Up" = "resize shrink height 10 px or 10 ppt";
            "Right" = "resize grow width 10 px or 10 ppt";

            # back to normal: Enter or Escape or $mod+r
            "Return" = "mode \"default\"";
            "Escape" = "mode \"default\"";
            "${modifier}+r" = "mode \"default\"";
          };
        };


        bars = [{
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
        }];

      };
    };

  programs.i3status-rust.enable = true;

  programs.carapace = {
    enable = true;
    enableZshIntegration = true;
  };

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

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ../doom.d;
    # Only init/packages so we only rebuild when those change.
    doomPackageDir =
      let
        filteredPath = builtins.path {
          path = ../doom.d;
          name = "doom-private-dir-filtered";
          filter = path: type:
            builtins.elem (baseNameOf path) [ "init.el" "packages.el" ];
        };
      in
      pkgs.linkFarm "doom-packages-dir" [
        {
          name = "init.el";
          path = "${filteredPath}/init.el";
        }
        {
          name = "packages.el";
          path = "${filteredPath}/packages.el";
        }
        {
          name = "config.el";
          path = pkgs.emptyFile;
        }
      ];
  };

  services.emacs = {
    enable = true;
  };

  programs.neovim =
    let
      toLuaFile = file: "\n${builtins.readFile file}\n";
    in
    {
      enable = true;
      package = pkgs.neovim-nightly;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraPackages = with pkgs; [
        luajitPackages.lua-lsp
        rnix-lsp

        xclip
        wl-clipboard
      ];

      plugins = with pkgs.vimPlugins; [
        rust-tools-nvim
        nvim-jdtls
        {
          type = "lua";
          plugin = nvim-lspconfig;
          config = ''
            ${toLuaFile ../nvim/plugin/lsp.lua}
          '';
        }
        lualine-nvim
        neodev-nvim
        vim-fugitive
        vim-rhubarb
        vim-sleuth
        luasnip
        friendly-snippets
        cmp_luasnip
        {
          type = "lua";
          plugin = nvim-cmp;
          config = toLuaFile ../nvim/plugin/cmp.lua;
        }
        cmp-nvim-lsp
        {
          type = "lua";
          plugin = which-key-nvim;
          config = "require('which-key').setup()";
        }
        gitsigns-nvim
        indent-blankline-nvim
        comment-nvim
        {
          type = "lua";
          plugin = telescope-nvim;
          config = toLuaFile ../nvim/plugin/telescope.lua;
        }
        telescope-fzf-native-nvim
        {
          type = "lua";
          plugin = (nvim-treesitter.withPlugins (p: [
            p.tree-sitter-nix
            p.tree-sitter-vim
            p.tree-sitter-bash
            p.tree-sitter-lua
            p.tree-sitter-python
            p.tree-sitter-json
            p.tree-sitter-typescript
            p.tree-sitter-tsx
            p.tree-sitter-rust
          ]));
          config = toLuaFile ../nvim/plugin/treesitter.lua;
        }
        nvim-autopairs
      ];

      extraLuaConfig = ''

      ${builtins.readFile ../nvim/options.lua}
      ${builtins.readFile ../nvim/plugin/other.lua}
    '';
    };

  services.dunst.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = [ "zathura.desktop" ];
      "application/pdf" = [ "zathura.desktop" ];
      "image/*" = [ "feh.desktop" ];
      "video/*" = [ "mpv.desktop" ];
      "inode/directory" = [ "thunar.desktop" ];
    };
  };

  home.file = {
    ".config/onedrive/config".text = ''
      sync_dir = "~/onedrive/OneDrive - TU Wien"
      sync_business_shared_folders = "true"
      skip_dir = "HTL Rennweg Backup"
      skip_dir = "Personal/Handy"
      skip_dir = "vaults/Geteilter Ordner"
      skip_dir = "vaults/PeterBezak"
      skip_dir = "vaults/TeadrinkingUnicornAnnihilator"
      skip_dir = "vaults/TU_Jeremiasz"
    '';

    ".config/onedrive/business_shared_folders".text = ''
      TU_Giftzwerg02 
    '';
    # ".config/i3".source = ../i3;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    GTK_THEME = "Catppuccin-Macchiato-Compact-Pink-dark";
  };

  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
