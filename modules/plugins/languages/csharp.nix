{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (builtins) concatMap;
  inherit (builtins) elem;
  inherit (lib) genAttrs;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) enum listOf;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption enumWithRename luaInline;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  extraServerPlugins = {
    omnisharp = ["omnisharp-extended-lsp-nvim"];
    csharp_ls = ["csharpls-extended-lsp-nvim"];
    roslyn-ls = [];
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
            Roslyn LSP plugin for Neovim that adds Razor support and works with multiple solutions

            ::: {.note}
            This feature only works for `roslyn-ls`.
            :::
          '';
          setupOpts = mkPluginSetupOption "roslyn-nvim" {
            filewatching = mkOption {
              description = ''
                "auto" | "roslyn" | "off"

                 - "auto": Does nothing for filewatching, leaving everything as default
                 - "roslyn": Turns off neovim filewatching which will make roslyn do the filewatching
                 - "off": Hack to turn off all filewatching.

                ::: {.tip}
                Set to "off" if you notice performance issues
                :::
              '';
              type = enum ["auto" "roslyn" "off"];
              default = "auto";
            };
            extensions.razor = {
              enabled =
                (mkEnableOption "Additional roslyn extensions (for example Roslynator/Razor)")
                // {default = true;};
              config = mkOption {
                description = "Configuration for the additional roslyn extensions";
                type = luaInline;
                default = let
                  pkg = pkgs.vscode-extensions.ms-dotnettools.csharp;
                  pluginRoot = "${pkg}/share/vscode/extensions/ms-dotnettools.csharp";
                  razorExtension = "${pluginRoot}/.razorExtension/Microsoft.VisualStudioCode.RazorExtension.dll";
                  razorSourceGenerator = "${pluginRoot}/.razorExtension/Microsoft.CodeAnalysis.Razor.Compiler.dll";
                  razorDesignTimePath = "${pluginRoot}/.razorExtension/Targets/Microsoft.NET.Sdk.Razor.DesignTime.targets";
                in
                  mkLuaInline ''
                    function()
                      return {
                        path = '${razorExtension}',
                        args = {
                          '--razorSourceGenerator=${razorSourceGenerator}',
                          '--razorDesignTimePath=${razorDesignTimePath}',
                        },
                      }
                    end
                  '';
              };
            };
          };
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
          type = listOf (enumWithRename
            "vim.languages.csharp.lsp.servers"
            servers {
              roslyn_ls = "roslyn-ls";
            });
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
    (mkIf (cfg.lsp.enable
      && cfg.extensions.roslyn-nvim.enable
      && (elem "roslyn-ls" cfg.lsp.servers)) {
      vim = {
        startPlugins = ["roslyn-nvim"];
        pluginRC.roslyn-nvim = entryAnywhere "require('roslyn').setup(${toLuaObject cfg.extensions.roslyn-nvim.setupOpts})";
        lsp.servers.roslyn-ls.enable = false;
        extraPackages = with pkgs; [roslyn-ls];
      };
    })
  ]);
}
