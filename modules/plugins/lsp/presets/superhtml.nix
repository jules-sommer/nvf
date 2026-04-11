{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.superhtml;
in {
  options.vim.lsp.presets.superhtml = {
    enable = mkEnableOption "the SuperHTML Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.superhtml = {
      enable = true;
      cmd = [(getExe pkgs.superhtml) "lsp"];
      root_markers = [".git"];
    };
  };
}
