{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.taplo;
in {
  options.vim.lsp.presets.taplo = {
    enable = mkEnableOption "the Taplo Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.taplo = {
      enable = true;
      cmd = [(getExe pkgs.taplo) "lsp" "stdio"];
      root_markers = [".git"];
    };
  };
}
