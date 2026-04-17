{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (builtins) concatMap;
  inherit (lib) genAttrs;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) enum listOf;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption;

  extraServerPlugins = {
    omnisharp = ["omnisharp-extended-lsp-nvim"];
    csharp_ls = ["csharpls-extended-lsp-nvim"];
    roslyn_ls = [];
    roslyn = ["roslyn-nvim"];
  };
  defaultServers = ["csharp-ls"];
  servers = ["csharp-ls" "omnisharp" "roslyn-ls"];

  cfg = config.vim.languages.csharp;
in {
  options = {
    vim.languages.csharp = {
      enable = mkEnableOption ''
        C# language support.

        ::: {.note}
        This feature will not work if the .NET SDK is not installed.
        Both `roslyn-ls` (with `roslyn-nvim`) and `csharp-ls` require the .NET SDK to function properly with Razor.
        Ensure that the .NET SDK is installed.

        Check for version compatibility for optimal performance.
        :::

        ::: {.warning}
        At the moment, only `roslyn-ls`(with roslyn-nvim) provides full Razor support.
        `csharp-ls` is limited to `.cshtml` files.
        :::
      '';

      extensions = {
        roslyn-nvim = {
          enable = mkEnableOption ''
            Roslyn LSP plugin for neovim

            ::: {.note}
            This feature only works for `roslyn-ls`.
            :::
          '';
          setupOpts = mkPluginSetupOption "roslyn-nvim" {};
        };
      };

      treesitter = {
        enable =
          mkEnableOption "C# treesitter"
          // {
            default = config.vim.languages.enableTreesitter;
            defaultText = literalExpression "config.vim.languages.enableTreesitter";
          };
        csPackage = mkGrammarOption pkgs "c_sharp";
        razorPackage = mkGrammarOption pkgs "razor";
      };

      lsp = {
        enable =
          mkEnableOption "C# LSP support"
          // {
            default = config.vim.lsp.enable;
            defaultText = literalExpression "config.vim.lsp.enable";
          };
        servers = mkOption {
          description = "C# LSP server to use";
          type = listOf (enum servers);
          default = defaultServers;
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = with cfg.treesitter; [csPackage razorPackage];
    })

    (mkIf cfg.lsp.enable {
      vim = {
        startPlugins = concatMap (server: extraServerPlugins.${server}) cfg.lsp.servers;
        luaConfigRC.razorFileTypes =
          /*
          lua
          */
          ''
            -- Set unknown file types!
            vim.filetype.add {
              extension = {
                razor = "razor",
                cshtml = "razor",
              },
            }
          '';
        lsp = {
          presets = genAttrs cfg.lsp.servers (_: {enable = true;});
          servers = genAttrs cfg.lsp.servers (_: {
            filetypes = ["cs" "razor" "vb"];
          });
        };
      };
    })
    (mkIf cfg.extensions.roslyn-nvim.enable {
      vim = mkMerge [
        {
          startPlugins = ["roslyn-nvim"];
        }
      ];
    })
  ]);
}
