{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib) concatStringsSep genAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption diagnostics deprecatedSingleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.nix;

  defaultServers = ["nil"];
  servers = ["nil" "nixd"];

  defaultFormat = ["alejandra"];
  formats = {
    alejandra = {
      command = getExe pkgs.alejandra;
    };

    nixfmt = {
      command = getExe pkgs.nixfmt;
    };
  };

  defaultDiagnosticsProvider = ["statix" "deadnix"];
  diagnosticsProviders = {
    statix = {
      package = pkgs.statix;
      nullConfig = pkg: ''
        table.insert(
          ls_sources,
          null_ls.builtins.diagnostics.statix.with({
            command = "${pkg}/bin/statix",
          })
        )
      '';
    };

    deadnix = {
      package = pkgs.deadnix;
      nullConfig = pkg: ''
        table.insert(
          ls_sources,
          null_ls.builtins.diagnostics.deadnix.with({
            command = "${pkg}/bin/deadnix",
          })
        )
      '';
    };
  };
in {
  options.vim.languages.nix = {
    enable = mkEnableOption "Nix language support";

    treesitter = {
      enable =
        mkEnableOption "Nix treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "nix";
    };

    lsp = {
      enable =
        mkEnableOption "Nix LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Nix LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Nix formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        description = "Nix formatter to use";
        type = deprecatedSingleOrListOf "vim.language.nix.format.type" (enum (attrNames formats));
        default = defaultFormat;
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Nix diagnostics"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };

      types = diagnostics {
        langDesc = "Nix";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.format.type != "nixpkgs-fmt";
          message = ''
            nixpkgs-fmt has been archived upstream. Please use one of the following available formatters:
            ${concatStringsSep ", " (attrNames formats)}
          '';
        }
      ];
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
        queries = [
          # vim.treesitter.queries.*.content
          {
            type = "injections";
            filetypes = ["nix"];
            content = ''
              ;; extends
              (
                (binding
                  attrpath: (attrpath
                    (identifier) @_a
                    (identifier) @_b
                    (identifier)? @_c)
                  (#eq? @_a "vim")
                  (#any-of? @_b "treesitter")
                  (#any-of? @_c "queries")

                  expression: (attrset_expression
                    (binding_set
                      (binding
                        attrpath: (attrpath
                          (identifier) @_queries)
                        (#eq? @_queries "queries")

                        expression: (list_expression
                          (attrset_expression
                            (binding_set
                              (binding
                                attrpath: (attrpath
                                  (identifier) @_field)
                                (#eq? @_field "content")

                                expression: [
                                  (string_expression
                                    (string_fragment) @injection.content)
                                  (indented_string_expression
                                    (string_fragment) @injection.content)
                                ]

                                (#set! injection.language "query")
                                (#set! injection.combined)))))))))
              )
            '';
          }
          # mkLuaInline = lua
          {
            type = "injections";
            filetypes = ["nix"];
            content = ''
              ;; extends

              ((apply_expression
                function: (variable_expression
                  name: (identifier) @_func
                  (#eq? @_func "mkLuaInline"))

                argument: (indented_string_expression
                  (string_fragment) @injection.content)

                (#set! injection.language "lua")
                (#set! injection.combined)))
            '';
          }
        ];
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["nix"];
          root_markers = ["flake.nix"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.nix = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.nix = cfg.extraDiagnostics.types;
        linters = mkMerge (map (name: {
            ${name}.cmd = getExe diagnosticsProviders.${name}.package;
          })
          cfg.extraDiagnostics.types);
      };
    })
  ]);
}
