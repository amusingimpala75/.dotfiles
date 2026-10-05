{
  inputs,
  ...
}:
{
  flake.modules.homeManager.pi =
    {
      config,
      pkgs,
      ...
    }:
    let
      config-dir = ".config/pi/agent";
    in
    {
      imports = [
        "${inputs.home-manager}/modules/programs/pi-coding-agent.nix"
      ];

      programs.pi-coding-agent = {
        enable = true;
        context = ./global-agents.md;
        configDir = "${config.home.homeDirectory}/${config-dir}";
        package = pkgs.bleeding.pi-coding-agent;
        settings = {
          defaultModel = "gpt-6.1-sol";
          defaultProvider = "openai-codex";
          defaultThinkingLevel = "medium";
          defaultTools = [
            "+codemode"
            "+tool_search"
          ];
          enableInstallTelemetry = false;
          extensions =
            with pkgs;
            with pi-extensions;
            [
              commands
              notify
              permission-gate
              pi-sandbox
              pi-telegram
              plan-mode
              protected-paths
              subagent
              tools
            ];
          quietStartup = "header";
          tuiMode = "regular";
        };
      };

      sops.secrets."deepseek_api_key" = { };

      home = {
        sessionVariables = {
          PI_AGENT_DIR = "${config.home.homeDirectory}/${config-dir}/sessions"; # Stupid ccusage
          PI_OFFLINE = 1;
          DEEPSEEK_API_KEY = "$(cat ${config.sops.secrets.deepseek_api_key.path})";
        };

        packages =
          with pkgs;
          [
            ccusage
          ]
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux (
            with pkgs;
            [
              bubblewrap
              socat
            ]
          ));

        # Custom agents and skills remain mutable, out-of-store resources.
        file."${config-dir}/agents".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/pi/agents";
        file."${config-dir}/skills".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/pi/skills";
        file."${config-dir}/sandbox.json".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/pi/sandbox.json";
      };
    };
}
