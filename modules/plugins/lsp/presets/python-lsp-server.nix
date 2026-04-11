{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.python-lsp-server;
in {
  options.vim.lsp.presets.python-lsp-server = {
    enable = mkEnableOption "the Python Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.python-lsp-server = {
      enable = true;
      cmd = [(getExe pkgs.python3Packages.python-lsp-server)];
      root_markers = [".git"];
    };
  };
}
