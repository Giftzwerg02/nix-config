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
