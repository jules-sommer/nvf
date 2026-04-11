{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.nixd;
in {
  options.vim.lsp.presets.nixd = {
    enable = mkEnableOption "the NixD Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.nixd = {
      enable = true;
      cmd = [(getExe pkgs.nixd)];
      root_markers = [".git"];
    };
  };
}
