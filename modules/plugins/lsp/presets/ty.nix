{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.ty;
in {
  options.vim.lsp.presets.ty = {
    enable = mkEnableOption "the ty Python Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.ty = {
      enable = true;
      cmd = [(getExe pkgs.ty) "server"];
      root_markers = [".git"];
    };
  };
}
