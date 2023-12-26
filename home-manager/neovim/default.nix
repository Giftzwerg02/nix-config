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

      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      options = {
        hlsearch = true;
        mouse = "a";
        breakindent = true;
        undofile = true;
        ignorecase = true;
        smartcase = true;
        updatetime = 250;
        timeout = true;
        timeoutlen = 300;
        completeopt = "menuone,noselect";
        termguicolors = true;
      };

      extraConfigLua = ''
        vim.wo.relativenumber = true
        vim.wo.number = true
      '';

      keymaps = [
        {
          mode = "n";
          key = "k";
          action = "v:count == 0 ? 'gk' : 'k'";
          options = {
            expr = true;
            silent = true;
          };
        }

        {
          mode = "n";
          key = "j";
          action = "v:count == 0 ? 'gj' : 'j'";
          options = {
            expr = true;
            silent = true;
          };
        }

        {
          mode = "n";
          key = "[d";
          action = "vim.diagnostic.goto_prev";
          lua = true;
          options = {
            desc = "Go to previous diagnostic message";
          };
        }

        {
          mode = "n";
          key = "]d";
          action = "vim.diagnostic.goto_next";
          lua = true;
          options = {
            desc = "Go to next diagnostic message";
          };
        }

        {
          mode = "n";
          key = "<leader>e";
          action = "vim.diagnostic.open_float";
          lua = true;
          options = {
            desc = "Open floating diagnostic message";
          };
        }

        {
          mode = "n";
          key = "<leader>q";
          action = "vim.diagnostic.setloclist";
          lua = true;
          options = {
            desc = "Open diagnostics list";
          };
        }
      ];

      autoCmd = [
        {
          event = "TextYankPost";
          group = "YankHighlight";
          callback = "vim.highlight.on_yank";
        }

        {
          event = "LspAttach";
          group = "UserLspConfig";
          callback = {
            __raw = ''
              function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client.server_capabilities.inlayHintProvider then
                  vim.lsp.inlay_hint(0, true)
                  vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "grey" })
                end
              end
            '';
          };
        }
      ];

      autoGroups = {
        "YankHighlight" = { clear = true; };
        "UserLspConfig" = {};
      };

      clipboard = {
        register = "unnamedplus";
        providers = {
          wl-copy.enable = true;
          xclip.enable = true;
        };
      };

      plugins = {
        rust-tools.enable = true;
        lualine.enable = true;
        fugitive.enable = true;
        luasnip.enable = true;
        cmp_luasnip.enable = true;
        cmp-nvim-lsp.enable = true;
        which-key.enable = true;
        gitsigns.enable = true;
        indent-blankline.enable = true;
        comment-nvim.enable = true;
        nvim-autopairs.enable = true;

        telescope = {
          enable = true;
          defaults = {
            mappings = {
              i = {
                "<C-u>" = false;
                "<C-d>" = false;
              };
            };
          };
          extensions = {
            fzf-native = {
              enable = true;
              overrideGenericSorter = true;
              overrideFileSorter = true;
              caseMode = "smart_case";
            };
          };
          keymaps = {
            
            "<leader>/" = {
              action = "current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })";
              desc = "[/] Fuzzily search in current buffer";
            };

          };
        };

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
                end)
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
                end)
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

        treesitter = {
          enable = true;
          ensureInstalled = [
            "vim"
            "bash"
            "lua"
            "python"
            "json"
            "typescript"
            "tsx"
            "rust"
            "latex"
          ];
          folding = true;
          indent = true;
        };
        treesitter-textobjects = {
          enable = true;
          select = {
            enable = true;
            lookahead = true;
            keymaps = {
              "aa" = "@parameter.outer";
              "ia" = "@parameter.inner";
              "af" = "@function.outer";
              "if" = "@function.inner";
              "ac" = "@class.outer";
              "ic" = "@class.inner";
            };
          };
          move = {
            enable = true;
            gotoNextStart = {
              "]m" = "@function.outer";
              "]]" = "@class.outer";
            };

            gotoNextEnd = {
              "]M" = "@function.outer";
              "][" = "@class.outer";
            };


            gotoPreviousStart = {
              "[m" = "@function.outer";
              "[[" = "@class.outer";
            };

            gotoPreviousEnd = {
              "[M" = "@function.outer";
              "[]" = "@class.outer";
            };
          };
          swap = {
            enable = true;
            swapNext = {
              "<leader>a" = "@parameter.inner";
            };
            swapPrevious = {
              "<leader>A" = "@parameter.inner";
            };
          };
        };

        lsp = {
          enable = true;
          servers = {
            rnix-lsp.enable = true;
          };
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




    #     extraLuaConfig = ''
    #       ${builtins.readFile ./nvim/options.lua}
    #       ${builtins.readFile ./nvim/plugin/other.lua}
    #     '';
    #   };
  };
}
