{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.just-lsp;
in {
  options.vim.lsp.presets.just-lsp = {
    enable = mkEnableOption "the Just Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.just-lsp = {
      enable = true;
      cmd = [(getExe pkgs.just-lsp)];
      root_markers = [".git" "Justfile" "justfile"];
    };
  };
}
