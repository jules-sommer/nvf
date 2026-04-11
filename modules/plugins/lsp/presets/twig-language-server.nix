{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.twig-language-server;
in {
  options.vim.lsp.presets.twig-language-server = {
    enable = mkEnableOption "Twig Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.twig-language-server = {
      enable = true;
      cmd = [(getExe pkgs.twig-language-server) "--stdio"];
      root_markers = [".git"];
    };
  };
}
