{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.lsp.presets.lua-language-server;
in {
  options.vim.lsp.presets.lua-language-server = {
    enable = mkEnableOption "the Lua Language Server";
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.lua-language-server = {
      enable = true;
      cmd = [(getExe pkgs.lua-language-server)];
      root_markers = [
        ".luarc.json"
        ".luarc.jsonc"
        ".luacheckrc"
        ".stylua.toml"
        "stylua.toml"
        "selene.toml"
        "selene.yml"
        ".git"
      ];
    };
  };
}
