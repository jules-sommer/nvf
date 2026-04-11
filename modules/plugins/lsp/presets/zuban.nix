{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.zuban;
in {
  options.vim.lsp.presets.zuban = {
    enable = mkEnableOption "the Zuban Python Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.zuban = {
      enable = true;
      cmd = [(getExe pkgs.zuban) "server"];
      root_markers = [".git"];
    };
  };
}
