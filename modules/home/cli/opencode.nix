{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.my.opencode = {
    enable = lib.mkEnableOption "enable opencode";
  };

  config = lib.mkIf config.my.opencode.enable {
    programs.opencode = {
      enable = true;
      package = pkgs.opencode;
      settings = {
        model = "openrouter/mistralai/devstral-2512:free";
        autoupdate = false;
        theme = "system";
        enabled_providers = [ "openrouter" ];
        provider.openrouter.options.apiKey = "{file:${config.sops.templates.openrouter_api_key.path}}";
      };
    };

    xdg.configFile."opencode/plugin/ralph.ts".source = "${inputs.opencode-ralph}/plugin/ralph.ts";
    # For some reason commands.<name> = inputs.<input> + "/path" doesn't link it,
    # it assumes that is the contents itself.
    xdg.configFile."opencode/command/cancel-ralph.md".source =
      "${inputs.opencode-ralph}/command/cancel-ralph.md";
    xdg.configFile."opencode/command/ralph-help.md".source =
      "${inputs.opencode-ralph}/command/ralph-help.md";
    xdg.configFile."opencode/command/ralph-loop.md".source =
      "${inputs.opencode-ralph}/command/ralph-loop.md";

    sops.secrets.openrouter_api_key = { };
    sops.templates.openrouter_api_key.content = "${config.sops.placeholder.openrouter_api_key}";

    home.sessionVariables.OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
  };
}
