{
  inputs,
  self,
  ...
}:
{
  # Reusable home module for pi
  flake.homeModules.pi =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.programs.pi = {
        enable = lib.mkEnableOption "pi coding agent";
        configDir = lib.mkOption {
          description = "path of the coding agent home relative to ~";
          default = ".pi/agent";
          example = ".config/pi/agent";
          type = lib.types.str;
        };
        "AGENTS.md" = lib.mkOption {
          description = "global AGENTS.md";
          default = null;
          example = ./AGENTS.md;
          type = lib.types.nullOr lib.types.path;
        };
        package = lib.mkPackageOption pkgs.llm-agents "pi" { };
        settings = lib.mkOption {
          description = "settings for pi (see docs/settings.md)";
          default = null;
          example = {
            defaultProvider = "openai";
          };
          type = lib.types.nullOr lib.types.json;
        };
      };
      config = lib.mkIf config.programs.pi.enable {
        home = {
          packages = [ config.programs.pi.package ];
          sessionVariables.PI_CODING_AGENT_DIR = "~/${config.programs.pi.configDir}";

          file = {
            "${config.programs.pi.configDir}/AGENTS.md".source = config.programs.pi."AGENTS.md";
            "${config.programs.pi.configDir}/settings.json".text = lib.mkIf (
              config.programs.pi.settings != null
            ) (builtins.toJSON config.programs.pi.settings);
          };
        };
      };
    };

  # My configuration for pi
  flake.modules.homeManager.pi =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [ self.homeModules.pi ];
      home.packages = [ pkgs.pi-acp ];
      programs.pi = {
        enable = true;
        "AGENTS.md" = ./global-agents.md;
        configDir = ".config/pi/agent";
        package = inputs.agent-sandbox.lib.${pkgs.stdenv.hostPlatform.system}.mkSandbox {
          pkg = pkgs.pi-coding-agent;
          binName = "pi";
          outName = "piw";
          allowedPackages = with pkgs; [
            bash
            coreutils
            fd
            findutils
            git
            gnugrep
            gnused
            jq
            jujutsu
            config.nix.package
            ripgrep
            which
          ];
          stateDirs = [ "$HOME/${config.programs.pi.configDir}" ];
          extraEnv = {
            inherit (config.home.sessionVariables) PI_CODING_AGENT_DIR;
          };
        };
        settings = {
          defaultProvider = "github-copilot";
          defaultModel = "gpt-5.3-codex";
          defaultThinkingLevel = "high";
          extensions =
            let
              fileExtension = name: "${inputs.pi-extensions}/${name}.ts";
              complexExtension =
                name: hash:
                let
                  pkg = pkgs.buildNpmPackage {
                    pname = "pi-${name}";
                    version = "git";
                    src = "${inputs.pi-extensions}/${name}";
                    npmDepsHash = hash;
                  };
                in
                "${pkg}/lib/node_modules";
              officialExtension =
                args: if builtins.isString args then fileExtension args else complexExtension args.name args.hash;
            in
            map officialExtension [
              "commands"
              "confirm-destructive"
              "dirty-repo-guard"
              "doom-overlay/index"
              "permission-gate"
              "protected-paths"
              "status-line"
              "titlebar-spinner"
              "tools"
            ];
        };
      };
    };
}
