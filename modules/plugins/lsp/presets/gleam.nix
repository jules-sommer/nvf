{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.gleam;
in {
  options.vim.lsp.presets.gleam = {
    enable = mkEnableOption "the Gleam Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.gleam = {
      enable = true;
      cmd = [(getExe pkgs.gleam) "lsp"];
      root_markers = [".git" "gleam.toml"];
    };
  };
}
