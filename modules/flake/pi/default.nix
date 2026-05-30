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
      inherit (pkgs.bleeding) pi-coding-agent;
      build =
        {
          outName ? null,
          allowNix ? false,
          allowedPackages ? [ ],
          rwDirs ? [ ],
          rwFiles ? [ ],
          roDirs ? [ ],
          roFiles ? [ ],
          env ? { },
        }:
        inputs.agent-sandbox.lib.${pkgs.stdenv.hostPlatform.system}.mkSandbox {
          pkg = pi-coding-agent;
          binName = "pi";
          outName = if outName != null then outName else "pi-wrapped";
          allowedPackages =
            with pkgs;
            [
              bash
              coreutils
              fd
              findutils
              config.wrappers.custom-git.wrapper
              gnugrep
              gnused
              jq
              config.wrappers.jujutsu-weave.wrapper
              ripgrep
              which

              rtk
            ]
            ++ allowedPackages;
          rwDirs = [
            "$HOME/${config.programs.pi.configDir}"
            "$HOME/Library/Application Support/rtk"
          ]
          ++ rwDirs;
          roDirs = [
            pkgs.rtk.src
            pi-coding-agent.src
            inputs.pi-cd
            pi-minimal-footer
          ]
          ++ roDirs;
          inherit
            rwFiles
            roFiles
            allowNix
            ;
          env = {
            inherit (config.home.sessionVariables) PI_CODING_AGENT_DIR PI_OFFLINE;
            DEEPSEEK_API_KEY = "$(cat ${config.sops.secrets.deepseek_api_key.path})";
            RTK_TELEMETRY_DISABLED = 1;
          }
          // env;
        };
      pi-minimal-footer = pkgs.runCommand "pi-minimal-footer" { } ''
        mkdir -p $out
        substitute ${inputs.pi-minimal-footer + "/index.ts"} $out/pi-minimal-footer.ts \
            --replace-fail '{ buildSessionContext }' '{ buildSessionContext, getAgentDir }' \
            --replace-fail 'homedir(), ".pi", "agent"' 'getAgentDir()'
      '';

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
            (build { })
            (build {
              outName = "pi-nix";
              allowNix = true;
              allowedPackages = with pkgs; [
                config.wrappers.nix-init.wrapper
                nurl
              ];
              roFiles = [
                "${config.sops.templates."nix-gh-ro-access.conf".path}"
              ];
              roDirs = [
                "$HOME/.config/nix"
              ];
              rwDirs = [
                "$HOME/.cache/nix"
                "$HOME/.local/share/nix"
              ];
            })
            (build {
              outName = "pi-go";
              allowedPackages = [ pkgs.go ];
              rwDirs = [
                "$HOME/go/pkg"
              ];
            })
          ];
        };
        settings = {
          defaultProvider = "openai-codex";
          defaultModel = "gpt-5.5";
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
              "notify"
              "plan-mode/index"
              "permission-gate"
              "protected-paths"
              "status-line"
              # "subagent"
              "tools"
            ])
            ++ [
              "${pkgs.rtk.src}/hooks/pi/rtk.ts"
              "${inputs.pi-cd}/extensions/cd.ts"
              pi-minimal-footer
            ];
        };
      };

      home.sessionVariables.PI_AGENT_DIR = "$HOME/${config.programs.pi.configDir}/sessions";
      home.packages = [
        inputs.ccusage.packages.${pkgs.stdenv.hostPlatform.system}.ccusage
        pkgs.rtk
      ];
    };

  flake-file.inputs = {
    agent-sandbox = {
      url = "github:archie-judd/agent-sandbox.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ccusage = {
      url = "github:ryoppippi/ccusage";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agent-skills.follows = "";
    };

    pi-cd = {
      url = "github:Acelogic/pi-cd";
      flake = false;
    };

    pi-minimal-footer = {
      url = "github:ogulcancelik/pi-extensions?dir=packages/pi-minimal-footer";
      flake = false;
    };
  };
}
