{
  config,
  lib,
  ...
}:
{
  options.my.opencode = {
    enable = lib.mkEnableOption "enable opencode";
  };

  config = lib.mkIf config.my.opencode.enable {
    programs.opencode = {
      enable = true;
      settings = {
        model = "mistralai/devstral-2512:free";
        autoupdate = "notify";
        theme = "system";
        enabled_providers = [ "openrouter" ];
        provider.openrouter.options.apiKey = "{file:${config.sops.templates.openrouter_api_key.path}}";
      };
    };

    sops.secrets.openrouter_api_key = { };
    sops.templates.openrouter_api_key.content = ''${config.sops.placeholder.openrouter_api_key}'';
  };
}
