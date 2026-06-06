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
        noUpdateNotice = lib.mkEnableOption "disable update check";
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
        package = lib.mkPackageOption pkgs "pi-coding-agent" { };
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
          sessionVariables.PI_OFFLINE = lib.mkIf config.programs.pi.noUpdateNotice 1;

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
    let
      inherit (inputs.pi-nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}) pi-coding-agent;
      build =
        update:
        inputs.agent-sandbox.lib.${pkgs.stdenv.hostPlatform.system}.mkSandbox (update {
          pkg = pi-coding-agent;
          binName = "pi";
          outName = "pi-wrapped";
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
            ripgrep
            which

            rtk
            rtk.src

            pi-coding-agent.src
            inputs.pi-quota-usage
          ];
          stateDirs = [
            "$HOME/${config.programs.pi.configDir}"
            "$HOME/Library/Application Support/rtk"
          ];
          stateFiles = [ ];
          extraEnv = {
            inherit (config.home.sessionVariables) PI_CODING_AGENT_DIR PI_OFFLINE;
            RTK_TELEMETRY_DISABLED = 1;
          };
        });
    in
    {
      imports = [ self.homeModules.pi ];
      programs.pi = {
        enable = true;
        "AGENTS.md" = ./global-agents.md;
        configDir = ".config/pi/agent";
        noUpdateNotice = true;
        package = pkgs.symlinkJoin {
          name = "pi-configs";
          paths = [
            (build (old: old))
            (build (
              old:
              old
              // {
                outName = "${old.outName}-nix";
                allowedPackages = old.allowedPackages ++ [ config.nix.package ];
                stateFiles = old.stateFiles ++ [
                  "/nix/var/nix/daemon-socket/socket"
                ];
              }
            ))
          ];
        };
        settings = {
          defaultProvider = "github-copilot";
          defaultModel = "gpt-5.3-codex";
          defaultThinkingLevel = "high";
          enableInstallTelemetry = false;
          extensions =
            let
              pi-extensions = "${pi-coding-agent.src}/packages/coding-agent/examples/extensions";
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
              "confirm-destructive"
              "dirty-repo-guard"
              "doom-overlay/index"
              "permission-gate"
              "protected-paths"
              "status-line"
              "titlebar-spinner"
              "tools"
            ])
            ++ [
              "${inputs.pi-quota-usage}/extensions/index.ts"
              "${pkgs.rtk.src}/hooks/pi/rtk.ts"
            ];
        };
      };

      home.sessionVariables.PI_AGENT_DIR = "$HOME/${config.programs.pi.configDir}/sessions";
      home.packages = [ inputs.ccusage.packages.${pkgs.stdenv.hostPlatform.system}.ccusage ];
    };

  flake-file.inputs = {
    # [TODO] remove once upstream is fixed
    pi-nixpkgs.url = "github:nixos/nixpkgs?rev=726fd9f7993e5a6fc427f0441baa2dd63e84b615";

    agent-sandbox = {
      url = "github:archie-judd/agent-sandbox.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pi-quota-usage = {
      url = "github:Limb/pi-quota-usage";
      flake = false;
    };

    ccusage = {
      url = "github:ryoppippi/ccusage";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agent-skills.follows = "";
    };
  };
}
