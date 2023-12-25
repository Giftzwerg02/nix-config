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
    programs.nixvim = {
      enable = true;

      plugins = {
        rust-tools.enable = true;
        lualine.enable = true;
        fugitive.enable = true;
        luasnip.enable = true;
        cmp_luasnip.enable = true;

        nvim-cmp = {
          enable = true;
          mapping = {
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<C-p>" = "cmp.mapping.select_prev_item()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete {}";
            "<CR>" = ''
              cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
              }
            '';
            "<Tab>" = {
              action = ''
                cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  elseif luasnip.expand_or_locally_jumpable() then
                    luasnip.expand_or_jump()
                  else
                    fallback()
                  end
                end
              '';
              modes = [ "i" "s" ];
            };

            "<S-Tab>" = {
              action = ''
                cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_prev_item()
                  elseif luasnip.locally_jumpable(-1) then
                    luasnip.jump(-1)
                  else
                    fallback()
                  end
                end
              '';
              modes = [ "i" "s" ];
            };
          };

          snippet.expand = "luasnip";

          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
          ];
        };

        lsp = {
          enable = true;
          servers = {
            rnix-lsp.enable = true;
          };
          capabilities = "require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())";
          onAttach = ''          
              local nmap = function(keys, func, desc)
                if desc then
                  desc = 'LSP: ' .. desc
                end

                vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
              end

              nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
              nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

              nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
              nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
              nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
              nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
              nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
              nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

              -- See `:help K` for why this keymap
              nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
              nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

              -- Lesser used LSP functionality
              nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
              nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
              nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
              nmap('<leader>wl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
              end, '[W]orkspace [L]ist Folders')

              -- Create a command `:Format` local to the LSP buffer
              vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
                vim.lsp.buf.format()
              end, { desc = 'Format current buffer with LSP' })
          '';
          keymaps = { };
        };
      };
    };


    # programs.neovim =
    #   let
    #     toLuaFile = file: "\n${builtins.readFile file}\n";
    #   in
    #   {
    #     enable = true;
    #     package = pkgs.neovim-nightly;
    #
    #     viAlias = true;
    #     vimAlias = true;
    #     vimdiffAlias = true;
    #
    #     extraPackages = with pkgs; [
    #       luajitPackages.lua-lsp
    #       rnix-lsp
    #
    #       xclip
    #       wl-clipboard
    #     ];
    #
    #     plugins = with pkgs.vimPlugins; [
    #       rust-tools-nvim
    #       nvim-jdtls
    #       {
    #         type = "lua";
    #         plugin = nvim-lspconfig;
    #         config = ''
    #           ${toLuaFile ./nvim/plugin/lsp.lua}
    #         '';
    #       }
    #       lualine-nvim
    #       neodev-nvim
    #       vim-fugitive
    #       vim-rhubarb
    #       vim-sleuth
    #       luasnip
    #       friendly-snippets
    #       cmp_luasnip
    #       {
    #         type = "lua";
    #         plugin = nvim-cmp;
    #         config = toLuaFile ./nvim/plugin/cmp.lua;
    #       }
    #       cmp-nvim-lsp
    #       {
    #         type = "lua";
    #         plugin = which-key-nvim;
    #         config = "require('which-key').setup()";
    #       }
    #       gitsigns-nvim
    #       indent-blankline-nvim
    #       comment-nvim
    #       {
    #         type = "lua";
    #         plugin = telescope-nvim;
    #         config = toLuaFile ./nvim/plugin/telescope.lua;
    #       }
    #       telescope-fzf-native-nvim
    #       {
    #         type = "lua";
    #         plugin = (nvim-treesitter.withPlugins (p: [
    #           p.tree-sitter-nix
    #           p.tree-sitter-vim
    #           p.tree-sitter-bash
    #           p.tree-sitter-lua
    #           p.tree-sitter-python
    #           p.tree-sitter-json
    #           p.tree-sitter-typescript
    #           p.tree-sitter-tsx
    #           p.tree-sitter-rust
    #           p.tree-sitter-latex
    #         ]));
    #         config = toLuaFile ./nvim/plugin/treesitter.lua;
    #       }
    #       nvim-autopairs
    #     ];
    #
    #     extraLuaConfig = ''
    #       ${builtins.readFile ./nvim/options.lua}
    #       ${builtins.readFile ./nvim/plugin/other.lua}
    #     '';
    #   };
  };
}
