{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.solargraph;
in {
  options.vim.lsp.presets.solargraph = {
    enable = mkEnableOption "the Ruby Solargraph Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.solargraph = {
      enable = true;
      cmd = [(getExe pkgs.rubyPackages.solargraph) "stdio"];
      root_markers = [".git"];
      settings = {
        solargraph = {
          diagnostics = true;
        };
      };
      flags = {
        debounce_text_changes = 150;
      };
      init_options = {
        formatting = true;
      };
    };
  };
}
