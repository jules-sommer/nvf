{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.clojure-lsp;
in {
  options.vim.lsp.presets.clojure-lsp = {
    enable = mkEnableOption "the Clojure Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.clojure-lsp = {
      enable = true;
      cmd = [(getExe pkgs.clojure-lsp)];
      root_markers = [".git" "project.clj"];
    };
  };
}
