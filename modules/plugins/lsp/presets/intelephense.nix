{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.intelephense;
in {
  options.vim.lsp.presets.intelephense = {
    enable = mkEnableOption "the Intelephense Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.intelephense = {
      enable = true;
      cmd = [(getExe pkgs.intelephense) "--stdio"];
      root_markers = [".git"];
    };
  };
}
