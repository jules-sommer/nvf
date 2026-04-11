{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.harper;
in {
  options.vim.lsp.presets.harper = {
    enable = mkEnableOption "the Harper grammar checking LSP";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.harper = {
      enable = true;
      cmd = [(getExe pkgs.harper) "--stdio"];
      root_markers = [".git" ".harper-dictionary.txt"];
      filetypes = [
        # <https://writewithharper.com/docs/integrations/language-server#Supported-Languages>
        "asciidoc"
        "c"
        "clojure"
        "cmake"
        "cpp"
        "cs"
        "daml"
        "dart"
        "gitcommit"
        "go"
        "haskell"
        "html"
        "ink"
        "java"
        "javascript"
        "javascriptreact"
        "kotlin"
        "lhaskell"
        "lua"
        "mail"
        "markdown"
        "nix"
        "php"
        "python"
        "ruby"
        "rust"
      ];
    };
  };
}
