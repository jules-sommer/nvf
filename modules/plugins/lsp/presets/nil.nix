{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.nil;
in {
  options.vim.lsp.presets.nil = {
    enable = mkEnableOption "the Nil Nix Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.nil = {
      enable = true;
      cmd = [(getExe pkgs.nil)];
      root_markers = [".git"];
    };
  };
}
