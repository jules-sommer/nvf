{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.dart;
in {
  options.vim.lsp.presets.dart = {
    enable = mkEnableOption "the Dart Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.dart = {
      enable = true;
      cmd = [(getExe pkgs.dart) "language-server" "--protocol=lsp"];
      root_markers = [".git" "pubspec.yaml"];
      init_options = {
        onlyAnalyzeProjectsWithOpenFiles = true;
        suggestFromUnimportedLibraries = true;
        closingLabels = true;
        outline = true;
        flutterOutline = true;
      };
      settings = {
        dart = {
          completeFunctionCalls = true;
          showTodos = true;
        };
      };
    };
  };
}
