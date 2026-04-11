{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.typescript-go;
in {
  options.vim.lsp.presets.typescript-go = {
    enable = mkEnableOption "the experimental Typescript Go Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.typescript-go = {
      enable = true;
      cmd = [(getExe pkgs.typescript-go) "--lsp" "--stdio"];
      root_markers = [".git" "package.json"];
    };
  };
}
