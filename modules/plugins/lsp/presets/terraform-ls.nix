{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.terraform-ls;
in {
  options.vim.lsp.presets.terraform-ls = {
    enable = mkEnableOption "the Terraform Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.terraform-ls = {
      enable = true;
      cmd = [(getExe pkgs.terraform-ls) "serve"];
      root_markers = [".git"];
    };
  };
}
