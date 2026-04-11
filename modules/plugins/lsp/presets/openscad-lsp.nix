{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.openscad-lsp;
in {
  options.vim.lsp.presets.openscad-lsp = {
    enable = mkEnableOption "the Open SCAD Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.openscad-lsp = {
      enable = true;
      cmd = [(getExe pkgs.openscad-lsp) "--stdio"];
      root_markers = [".git"];
    };
  };
}
