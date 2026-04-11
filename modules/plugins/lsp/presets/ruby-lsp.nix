{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.ruby-lsp;
in {
  options.vim.lsp.presets.ruby-lsp = {
    enable = mkEnableOption "the Ruby Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.ruby-lsp = {
      enable = true;
      cmd = [(getExe pkgs.ruby-lsp)];
      root_markers = [".git"];
      init_options = {
        formatter = "auto";
      };
    };
  };
}
