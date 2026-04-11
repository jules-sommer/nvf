{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.pyrefly;
in {
  options.vim.lsp.presets.pyrefly = {
    enable = mkEnableOption "the Pyrefly Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.pyrefly = {
      enable = true;
      cmd = [(getExe pkgs.pyrefly) "lsp"];
      root_markers = [".git" "pyrefly.toml"];
    };
  };
}
