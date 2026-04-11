{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.wgsl-analyzer;
in {
  options.vim.lsp.presets.wgsl-analyzer = {
    enable = mkEnableOption "the WGSL-Analyzer Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.wgsl-analyzer = {
      enable = true;
      cmd = [(getExe pkgs.wgsl-analyzer)];
      root_markers = [".git"];
    };
  };
}
