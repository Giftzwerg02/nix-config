{ lib, config, pkgs, ... }:
let
  cfg = config.my-neovim-config;
in
{
  options = {
    my-neovim-config = {
      enable = lib.mkEnableOption "enable neovim config";
    };
  };

  config = lib.mkIf cfg.enable {
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
  };
}
