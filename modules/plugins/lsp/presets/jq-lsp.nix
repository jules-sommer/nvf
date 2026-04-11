{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.jq-lsp;
in {
  options.vim.lsp.presets.jq-lsp = {
    enable = mkEnableOption "the JQ Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.jq-lsp = {
      enable = true;
      cmd = [(getExe pkgs.jq-lsp)];
      root_markers = [".git"];
    };
  };
}
