{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.qmlls;
in {
  options.vim.lsp.presets.qmlls = {
    enable = mkEnableOption "the QML Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.qmlls = {
      enable = true;
      cmd = [(getExe' pkgs.kdePackages.qtdeclarative "qmlls")];
      root_markers = [".git"];
    };
  };
}
