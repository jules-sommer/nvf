{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.tombi;
in {
  options.vim.lsp.presets.tombi = {
    enable = mkEnableOption "the Tombi Language Server (AI Slop)";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.tombi = {
      enable = true;
      cmd = [(getExe pkgs.tombi) "lsp"];
      root_markers = [".git" "tombi.toml"];
    };
  };
}
