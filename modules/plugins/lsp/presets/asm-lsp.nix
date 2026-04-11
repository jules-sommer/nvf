{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.asm-lsp;
in {
  options.vim.lsp.presets.asm-lsp = {
    enable = mkEnableOption "the Assembly Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.asm-lsp = {
      enable = true;
      cmd = [(getExe pkgs.asm-lsp)];
      root_markers = [".git" ".asm-lsp.toml"];
    };
  };
}
