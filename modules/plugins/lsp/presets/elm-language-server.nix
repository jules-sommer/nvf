{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.elm-language-server;
in {
  options.vim.lsp.presets.elm-language-server = {
    enable = mkEnableOption "the Elm Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.elm-language-server = {
      enable = true;
      cmd = [(getExe pkgs.elmPackages.elm-language-server)];
      root_markers = [".git" "elm.json"];
      workspace_required = false;
    };
  };
}
