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
      programs.pi-coding-agent = {
        enable = true;
        context = ./global-agents.md;
        configDir = "${config.home.homeDirectory}/${config-dir}";
        settings = {
          defaultModel = "gpt-5.6-terra";
          defaultProvider = "openai-codex";
          defaultThinkingLevel = "high";
          defaultTools = [
            "+codemode"
            "+tool_search"
          ];
          enableInstallTelemetry = false;
          extensions =
            let
              pi-extensions = "${pkgs.pi-coding-agent.src}/packages/coding-agent/examples/extensions";
              fileExtension = name: "${pi-extensions}/${name}.ts";
              complexExtension =
                name: hash:
                let
                  pkg = pkgs.buildNpmPackage {
                    pname = "pi-${name}";
                    version = "git";
                    src = "${pi-extensions}/${name}";
                    npmDepsHash = hash;
                  };
                in
                "${pkg}/lib/node_modules";
              officialExtension =
                args: if builtins.isString args then fileExtension args else complexExtension args.name args.hash;
            in
            (map officialExtension [
              "commands"
              "notify"
              "plan-mode/index"
              "permission-gate"
              "protected-paths"
              "status-line"
              "tools"
            ])
            ++ [
              "${pkgs.pi-minimal-footer}/extensions/pi-minimal-footer.ts"
              "${pkgs.pi-telegram}/extensions/pi-telegram.ts"
              "${pkgs.pi-subagents}/lib/node_modules/@tintinweb"
              "${pkgs.gondolin.pi-extension}/extensions/pi-gondolin.ts"
            ];
          quietStartup = "header";
          skills = [
            ./skills
          ];
          tuiMode = "regular";
        };
      };

      sops.secrets."deepseek_api_key" = { };

      home = {
        sessionVariables = {
          PI_AGENT_DIR = "$HOME/${config-dir}/sessions"; # Stupid ccusage
          PI_OFFLINE = 1;
          DEEPSEEK_API_KEY = "$(cat ${config.sops.secrets.deepseek_api_key.path})";
        };

        packages = with pkgs; [
          ccusage
        ];

        # Custom agents, and to specify the models
        file."${config-dir}/agents".source = config.lib.file.mkOutOfStoreSymlink ./agents;
      };
    };
}
