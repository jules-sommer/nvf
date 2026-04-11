{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.phpactor;
in {
  options.vim.lsp.presets.phpactor = {
    enable = mkEnableOption "the PHPActor Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.phpactor = {
      enable = true;
      cmd = [(getExe pkgs.phpactor) "language-server"];
      root_markers = [".git" ".phpactor.json" ".phpactor.yml"];
      workspace_required = true;
    };
  };
}
