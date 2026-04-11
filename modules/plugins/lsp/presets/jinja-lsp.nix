{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.jinja-lsp;
in {
  options.vim.lsp.presets.jinja-lsp = {
    enable = mkEnableOption "the Jinja Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.jinja-lsp = {
      enable = true;
      cmd = [(getExe pkgs.jinja-lsp)];
      root_markers = [".git"];
    };
  };
}
