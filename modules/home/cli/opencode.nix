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
        model = "github-copilot/grok-code-fast-1";
        autoupdate = false;
        theme = "system";
        enabled_providers = [
          "openrouter"
          "github-copilot"
        ];
        provider.openrouter.options.apiKey = "{file:${config.sops.templates.openrouter_api_key.path}}";
        plugin = [
          "oh-my-opencode@v3.1.6"
        ];
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

    xdg.configFile."opencode/oh-my-opencode.json".text = builtins.toJSON {
      "$schema" =
        "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json";
      agents = {
        "Sisyphus" = {
          model = "github-copilot/claude-opus-4.5";
        };
        "oracle" = {
          model = "github-copilot/gpt-5.2";
        };
        "librarian" = {
          model = "github-copilot/grok-code-fast-1";
        };
        "explore" = {
          model = "github-copilot/gpt-5-mini";
        };
        "multimodal-looker" = {
          model = "github-copilot/gemini-3-flash";
        };
        "Prometheus" = {
          model = "github-copilot/claude-opus-4.5";
        };
        "Metis" = {
          model = "github-copilot/claude-sonnet-4.5";
        };
        "Momus" = {
          model = "github-copilot/claude-sonnet-4.5";
        };
      };
    };

    sops.secrets.openrouter_api_key = { };
    sops.templates.openrouter_api_key.content = "${config.sops.placeholder.openrouter_api_key}";

    home.sessionVariables.OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
  };
}
