{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.vscode-css-language-server;
in {
  options.vim.lsp.presets.vscode-css-language-server = {
    enable = mkEnableOption "the VSCode CSS Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.vscode-css-language-server = {
      enable = true;
      cmd = [(getExe' pkgs.vscode-langservers-extracted "vscode-css-language-server") "--stdio"];
      root_markers = [".git" "package.json"];
      init_options = {provideFormatter = true;};
      settings = {
        css.validate = true;
        scss.validate = true;
        less.validate = true;
      };
    };
  };
}
