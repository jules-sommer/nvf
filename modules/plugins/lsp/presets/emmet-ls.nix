{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.emmet-ls;
in {
  options.vim.lsp.presets.emmet-ls = {
    enable = mkEnableOption "the Emmet Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.emmet-ls = {
      enable = true;
      cmd = [(getExe pkgs.emmet-ls) "--stdio"];
      root_markers = [".git"];
    };
  };
}
