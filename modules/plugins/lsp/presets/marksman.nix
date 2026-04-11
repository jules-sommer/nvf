{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.marksman;
in {
  options.vim.lsp.presets.marksman = {
    enable = mkEnableOption "the Marksman Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.marksman = {
      enable = true;
      cmd = [(getExe pkgs.marksman) "server"];
      root_markers = [".git" ".marksman.toml"];
    };
  };
}
