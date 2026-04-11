{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) deprecatedSingleOrListOf;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.languages.tailwind;

  defaultServers = ["tailwindcss"];
  servers = {
    tailwindcss = {
      enable = true;
      cmd = [(getExe pkgs.tailwindcss-language-server) "--stdio"];
      before_init = mkLuaInline ''
        function(_, config)
          if not config.settings then
            config.settings = {}
          end
          if not config.settings.editor then
            config.settings.editor = {}
          end
          if not config.settings.editor.tabSize then
            config.settings.editor.tabSize = vim.lsp.util.get_effective_tabstop()
          end
        end
      '';
      workspace_required = true;
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local root_files = {
            -- Generic
            'tailwind.config.js',
            'tailwind.config.cjs',
            'tailwind.config.mjs',
            'tailwind.config.ts',
            'postcss.config.js',
            'postcss.config.cjs',
            'postcss.config.mjs',
            'postcss.config.ts',
            -- Django
            'theme/static_src/tailwind.config.js',
            'theme/static_src/tailwind.config.cjs',
            'theme/static_src/tailwind.config.mjs',
            'theme/static_src/tailwind.config.ts',
            'theme/static_src/postcss.config.js',
          }
          local fname = vim.api.nvim_buf_get_name(bufnr)
          root_files = util.insert_package_json(root_files, 'tailwindcss', fname)
          root_files = util.root_markers_with_field(root_files, { 'mix.lock', 'Gemfile.lock' }, 'tailwind', fname)
          on_dir(vim.fs.dirname(vim.fs.find(root_files, { path = fname, upward = true })[1]))
        end
      '';
    };
  };
in {
  options.vim.languages.tailwind = {
    enable = mkEnableOption "Tailwindcss language support";

    lsp = {
      enable =
        mkEnableOption "Tailwindcss LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = deprecatedSingleOrListOf "vim.language.tailwind.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "Tailwindcss LSP server to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })
  ]);
}
