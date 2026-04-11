{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.sqls;
in {
  options.vim.lsp.presets.sqls = {
    enable = mkEnableOption "the SQL Language Server";
  };

  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["sqls-nvim"];
      lsp.servers.sqls = {
        enable = true;
        cmd = [(getExe pkgs.sqls)];
        root_markers = ["config.yml"];
        on_attach = mkLuaInline ''
          function(client, bufnr)
            client.server_capabilities.execute_command = true
            require'sqls'.setup{}
          end
        '';
      };
    };
  };
}
