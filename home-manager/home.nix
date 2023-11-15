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

  home.username = "benjamin";
  home.homeDirectory = "/home/benjamin";

  home.packages = with pkgs; [
    dconf
  ];

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

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

  qt = {
    enable = true;
    platformTheme = "gtk";
    style.name = "adwaita-dark";
  };

  gtk = {
    enable = true;
    cursorTheme.package = pkgs.breeze-gtk;
    cursorTheme.name = "Breeze-Dark";
    theme = {
      name = "Catppuccin-Macchiato-Compact-Pink-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "compact";
        tweaks = [ "rimless" "black" ];
        variant = "macchiato";
      };
    };
    iconTheme.package = pkgs.gnome.adwaita-icon-theme;
    iconTheme.name = "Adwaita";
  };

  home.pointerCursor = {
    name = "capitaine-cursors";
    package = pkgs.capitaine-cursors;
    size = 24;
  };

  programs.zathura = {
    enable = true;
    options = {
      # catppuccin macchiato theme: https://github.com/catppuccin/zathura/blob/main/src/catppuccin-macchiato
      default-fg = "#CAD3F5";
      default-bg = "#24273A";

      completion-bg = "#363A4F";
      completion-fg = "#CAD3F5";
      completion-highlight-bg = "#575268";
      completion-highlight-fg = "#CAD3F5";
      completion-group-bg = "#363A4F";
      completion-group-fg = "#8AADF4";

      statusbar-fg = "#CAD3F5";
      statusbar-bg = "#363A4F";

      notification-bg = "#363A4F";
      notification-fg = "#CAD3F5";
      notification-error-bg = "#363A4F";
      notification-error-fg = "#ED8796";
      notification-warning-bg = "#363A4F";
      notification-warning-fg = "#FAE3B0";

      inputbar-fg = "#CAD3F5";
      inputbar-bg = "#363A4F";

      recolor-lightcolor = "#24273A";
      recolor-darkcolor = "#CAD3F5";

      index-fg = "#CAD3F5";
      index-bg = "#24273A";
      index-active-fg = "#CAD3F5";
      index-active-bg = "#363A4F";

      render-loading-bg = "#24273A";
      render-loading-fg = "#CAD3F5";

      highlight-color = "#575268";
      highlight-fg = "#F5BDE6";
      highlight-active-color = "#F5BDE6";
    };
  };

  programs.i3status-rust.enable = true;

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
    doomPrivateDir = ./doom.d;
    # Only init/packages so we only rebuild when those change.
    doomPackageDir =
      let
        filteredPath = builtins.path {
          path = ./doom.d;
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
            ${toLuaFile ./nvim/plugin/lsp.lua}
          '';
        }

        # local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
        #                 local workspace_dir = '~/jdtls/' .. project_name
        #                 local config = {
        #                   cmd = { 
        #                     '${pkgs.jdt-language-server}/bin/jdt-language-server',
        #                     '-data', workspace_dir
        #                   },
        #                  root_dir = vim.fn.getcwd(), 
        #                 }
        #
        #                 require('jdtls').start_or_attach(config)


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
          config = toLuaFile ./nvim/plugin/cmp.lua;
        }
        cmp-nvim-lsp
        {
          type = "lua";
          plugin = which-key-nvim;
          config = "require('which-key').setup()";
        }
        gitsigns-nvim
        {
          plugin = onedark-nvim;
          config = "colorscheme onedark";
        }
        indent-blankline-nvim
        comment-nvim
        {
          type = "lua";
          plugin = telescope-nvim;
          config = toLuaFile ./nvim/plugin/telescope.lua;
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
          config = toLuaFile ./nvim/plugin/treesitter.lua;
        }
        nvim-autopairs
      ];

      extraLuaConfig = ''

      ${builtins.readFile ./nvim/options.lua}
      ${builtins.readFile ./nvim/plugin/other.lua}
    '';
    };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        context = "ctrl+shift+period";
        mouse_middle_click = "do_action";
        frame_color = "#8AADF4";
        separator_color = "frame";
      };

      urgency_low = {
        background = "#24273A";
        foreground = "#CAD3F5";
        timeout = 10;
      };

      urgency_normal = {
        background = "#24273A";
        foreground = "#CAD3F5";
        timeout = 20;
      };

      urgency_critical = {
        background = "#24273A";
        foreground = "#CAD3F5";
        frame_color = "#F5A97F";
        timeout = 0;
      };
    };
  };


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
    ".config/i3".source = ./i3;
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
