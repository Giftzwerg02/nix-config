{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my-neovim-config;
in {
  options = {
    my-neovim-config = {
      enable = lib.mkEnableOption "enable neovim config";
      nixosConfigName = lib.mkOption {
        description = "Set this to the nixos-config name of the current machine";
        type = lib.types.str;
        default = null;
      };
      hmConfigName = lib.mkOption {
        description = "Set this to the home-manager-config name of the current machine";
        type = lib.types.str;
        default = null;
      };
    };
  };

  config = let
    lspKeymapsOnAttach =
      /*
      lua
      */
      ''
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
  in
    lib.mkIf cfg.enable {
      programs.nixvim = {
        enable = true;

        globals = {
          mapleader = " ";
          maplocalleader = " ";
        };

        opts = {
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
          tabstop = 4;
          shiftwidth = 4;
        };

        files = {
          "ftplugin/nix.lua" = {
            opts = {
              expandtab = true;
              shiftwidth = 2;
              tabstop = 2;
            };
          };

          "ftplugin/gleam.lua" = {
            opts = {
              expandtab = true;
              shiftwidth = 2;
              tabstop = 2;
            };
          };

          "ftplugin/c.lua" = {
            opts = {
              expandtab = true;
              shiftwidth = 2;
              tabstop = 2;
            };
          };

          "ftplugin/cpp.lua" = {
            opts = {
              expandtab = true;
              shiftwidth = 2;
              tabstop = 2;
            };
          };
        };

        extraPlugins = let
          clingoSyntaxPlugin = pkgs.vimUtils.buildVimPlugin {
            name = "vim-syntax-clingo";
            src = pkgs.fetchFromGitHub {
              owner = "rkaminsk";
              repo = "vim-syntax-clingo";
              rev = "9166d331ce66133716947ddabcd06a356807003c";
              hash = "sha256-q/Q88NbK5krM9Z10cc84hhULYcovAE8Gqmu04yuda3Q=";
            };
          };
        in [
          pkgs.vimPlugins.go-nvim
          clingoSyntaxPlugin
        ];

        extraConfigLua =
          /*
          lua
          */
          ''
                  vim.wo.relativenumber = true
                  vim.wo.number = true
            vim.filetype.add({ extension = { templ = "templ" }})

                  -- Maybe remove this as it is ugly and not that necessary
                  vim.keymap.set('n', '<leader>/', function()
                    -- You can pass additional configuration to telescope to change theme, layout, etc.
                    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                      winblend = 10,
                      previewer = false,
                    })
                  end, { desc = '[/] Fuzzily search in current buffer' })

            require('go').setup()
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
            key = "<leader>q";
            action = {
              __raw = "vim.diagnostic.setloclist";
            };
            options = {
              desc = "Open diagnostics list";
            };
          }
        ];

        autoCmd = [
          {
            event = "TextYankPost";
            group = "YankHighlight";
            pattern = "*";
            callback = {
              __raw =
                /*
                lua
                */
                ''
                  function()
                  	vim.highlight.on_yank()
                  end
                '';
            };
          }
        ];

        autoGroups = {
          "YankHighlight" = {clear = true;};
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
          neotest = {
            enable = true;
            adapters = {
              playwright.enable = false;
            };
          };

          web-devicons.enable = true;
          lualine.enable = true;
          fugitive.enable = true;
          luasnip.enable = true;
          cmp_luasnip.enable = true;
          cmp-nvim-lsp.enable = true;
          which-key.enable = true;
          gitsigns.enable = true;
          indent-blankline.enable = true;
          comment.enable = true;
          nvim-autopairs.enable = true;

          vimtex = {
            enable = false;
            settings.view_method = "zathura";
          };

          telescope = {
            enable = true;
            settings = {
              defaults = {
                mappings = {
                  i = {
                    "<C-u>" = false;
                    "<C-d>" = false;
                  };
                };
              };
            };
            extensions = {
              fzf-native = {
                enable = true;
                settings = {
                  override_generic_sorter = true;
                  override_file_sorter = true;
                  case_mode = "smart_case";
                };
              };
            };
            keymaps = {
              "<leader><space>" = {
                action = "buffers";
                options = {
                  desc = "[ ] Find existing buffers";
                };
              };

              "<leader>sf" = {
                action = "find_files";
                options = {
                  desc = "[S]earch [F]iles";
                };
              };

              "<leader>sg" = {
                action = "live_grep";
                options = {
                  desc = "[S]earch by [G]rep";
                };
              };

              "<leader>sd" = {
                action = "diagnostics";
                options = {
                  desc = "[S]earch [D]iagnostics";
                };
              };
            };
          };

          cmp = {
            enable = true;
            settings = {
              mapping = {
                "<C-n>" =
                  /*
                  lua
                  */
                  "cmp.mapping.select_next_item()";
                "<C-p>" =
                  /*
                  lua
                  */
                  "cmp.mapping.select_prev_item()";
                "<C-d>" =
                  /*
                  lua
                  */
                  "cmp.mapping.scroll_docs(-4)";
                "<C-f>" =
                  /*
                  lua
                  */
                  "cmp.mapping.scroll_docs(4)";
                "<C-Space>" =
                  /*
                  lua
                  */
                  "cmp.mapping.complete {}";
                "<CR>" =
                  /*
                  lua
                  */
                  ''
                     cmp.mapping.confirm {
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true,
                     }
                  '';
                "<Tab>" =
                  /*
                  lua
                  */
                  ''
                    cmp.mapping(function(fallback)
                      if cmp.visible() then
                    	cmp.select_next_item()
                      elseif require("luasnip").expand_or_locally_jumpable() then
                    	require("luasnip").expand_or_jump()
                      else
                    	fallback()
                      end
                    end, {"i", "s"})
                  '';

                "<S-Tab>" =
                  /*
                  lua
                  */
                  ''
                    cmp.mapping(function(fallback)
                      if cmp.visible() then
                    	cmp.select_prev_item()
                      elseif require("luasnip").locally_jumpable(-1) then
                    	require("luasnip").jump(-1)
                      else
                    	fallback()
                      end
                    end, {"i", "s"})
                  '';
              };
              snippet.expand =
                /*
                lua
                */
                ''
                  function(args)
                  	require("luasnip").lsp_expand(args.body)
                  end
                '';
              sources = [
                {name = "nvim_lsp";}
                {name = "luasnip";}
              ];
            };
          };

          treesitter = 
          {
            enable = true;
            grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars ++ [
            ];
            settings = {
              indent.enable = true;
              highlight = {
                additional_vim_regex_highlighting = true;
                enable = true;
              };

              parser_install_dir = {
                __raw = "vim.fs.joinpath(vim.fn.stdpath('data'), 'treesitter')";
              };
              sync_install = false;
            };
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

          rustaceanvim = {
            enable = false;
            settings.server = {
              on_attach =
                /*
                lua
                */
                ''function(client, bufnr) ${lspKeymapsOnAttach} end '';
            };
          };

          # typescript-tools.enable = true;

          conform-nvim = {
            settings = {
              default_format_opts = {
                lsp_format = "fallback";
              };

              format_on_save = {
                lsp_format = "fallback";
                timeout_ms = 500;
              };

              formatters_by_ft = {
                javascript = ["prettier"];
                svelte = ["prettier"];
                css = ["prettier"];
                html = ["prettier"];
                json = ["prettier"];
                jsonc = ["prettier"];
                scss = ["prettier"];
                typescript = ["prettier"];
                yaml = ["prettier"];
              };
            };
          };

          lsp = {
            enable = true;
            servers = {
              sqls.enable = true;
              ts_ls = {
                enable = true;
                filetypes = [ "js" "mjs" "templ" "html" "ts" "tsx" "jsx" ];
              };
              clangd.enable = true;
              rust_analyzer = let
                my_ra = pkgs.rust-analyzer.overrideAttrs (old: {
                  version = "2025-03-10";
                });
              in {
                enable = true;
                installCargo = false;
                installRustc = false;
                package = my_ra;
                settings = {
                  cargo.features = "all";
                  check.command = "clippy";
                  diagnostics = {
                    enable = true;
                    refreshSupport = false;
                  };
                };
              };
              nixd = {
                enable = true;
                settings = {
                  formatting = {
                    command = ["${pkgs.alejandra}/bin/alejandra"];
                  };
                  options = {
                    nixos = {
                      expr = "(builtins.getFlake \"github:Giftzwerg02/nix-config\").nixosConfigurations.\"${cfg.nixosConfigName}\".options";
                    };
                    home_manager = {
                      expr = "(builtins.getFlake \"github:Giftzwerg02/nix-config\").homeConfigurations.\"${cfg.hmConfigName}\".options";
                    };
                  };
                };
              };
              lua_ls.enable = true;
              ruff.enable = true;
              pylsp = {
                enable = true;
                settings.plugins = {
                  ruff.enabled = true;
                  flake8 = {
                    enabled = true;
                    maxLineLength = 120;
                  };
                  isort.enabled = true;
                  pylint.enabled = true;
                  pylsp_mypy.enabled = true;
                };
              };
              svelte.enable = true;
              gopls.enable = true;
              templ.enable = true;
              html = {
                enable = true;
                filetypes = ["html" "templ"];
              };
              htmx = {
                enable = true;
                filetypes = ["html" "templ"];
              };
            };
            onAttach = lspKeymapsOnAttach;
          };
        };
      };
    };
}
