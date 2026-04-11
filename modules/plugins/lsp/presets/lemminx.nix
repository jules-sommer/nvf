{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.lemminx;
in {
  options.vim.lsp.presets.lemminx = {
    enable = mkEnableOption "Lemminx Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.lemminx = {
      enable = true;
      cmd = [(getExe pkgs.lemminx)];
      root_markers = [".git"];
    };
  };
}
