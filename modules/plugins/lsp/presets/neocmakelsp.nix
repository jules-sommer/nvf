{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.neocmakelsp;
in {
  options.vim.lsp.presets.neocmakelsp = {
    enable = mkEnableOption "the Neo CMake Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.neocmakelsp = {
      enable = true;
      cmd = [(getExe pkgs.neocmakelsp) "stdio"];
      root_markers = [".git" ".gersemirc"];
      capabilities = {
        textDocument.completion.completionItem.snippetSupport = true;
      };
    };
  };
}
