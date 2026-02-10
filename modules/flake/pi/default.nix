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
        settings = lib.mkOption {
          description = "settings for pi (see docs/settings.md)";
          default = null;
          example = { defaultProvider = "openai"; };
          type = lib.types.nullOr lib.types.json;
        };
      };

      config = lib.mkIf config.programs.pi.enable {
        nixpkgs.overlays = [ inputs.llm-agents.overlays.default ];
        home.packages = [ pkgs.llm-agents.pi ];
        home.sessionVariables.PI_CODING_AGENT_DIR = "~/${config.programs.pi.configDir}";

        home.file."${config.programs.pi.configDir}/AGENTS.md".source = config.programs.pi."AGENTS.md";
        home.file."${config.programs.pi.configDir}/settings.json".text = lib.mkIf (config.programs.pi.settings != null) (builtins.toJSON config.programs.pi.settings);
      };
    };

  # My configuration for pi
  flake.modules.homeManager.pi =
    {
      pkgs,
      ...
    }:
    {
      imports = [ self.homeModules.pi ];
      programs.pi = {
        enable = true;
        "AGENTS.md" = ./global-agents.md;
        configDir = ".config/pi/agent";
        settings = {
          defaultProvider = "github-copilot";
          defaultModel = "claude-sonnet-4.5";
          defaultThinkingLevel = "medium";
          extensions = [
            "${inputs.pi-extensions}/permission-gate.ts"
            "${inputs.pi-extensions}/protected-paths.ts"
            "${inputs.pi-extensions}/confirm-destructive"
            "${inputs.pi-extensions}/dirty-repo-guard.ts"
            "${inputs.pi-extensions}/tools.ts"
            (let
              pkg = pkgs.buildNpmPackage {
                pname = "pi-sandbox";
                version = "git";
                src = "${inputs.pi-extensions}/sandbox";
                npmDepsHash = "sha256-eJbT63DS557JrRE/dLLVITtZIHYsCxlowRJHIkSGKTc=";
              };
            in "${pkg}/lib/node_modules")
          ];
        };
      };
      home.packages = with pkgs; [ ripgrep bubblewrap socat ];
    };
}
