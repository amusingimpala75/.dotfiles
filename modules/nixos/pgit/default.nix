{
  config,
  lib,
  pkgs,
  ...
}:
let
  config' = config;

  mustacheRepositories = pkgs.writeTextFile {
    name = "data.yaml";
    text = lib.strings.toJSON config.services.pgit;
  };
in
{
  options.services.pgit = {
    enable = lib.mkEnableOption "pgit module";
    theme = lib.mkOption {
      type = lib.types.str;
      default = "dracula";
      example = "gruvbox";
      description = "Theme for the website. See https://xyproto.github.io/splash/docs/all.html for possible values";
    };
    homeUrl = lib.mkOption {
      type = lib.types.str;
      example = "https://git.mydomain.com";
      description = "URL of the repositories's homepage";
    };
    index = lib.mkOption {
      type = lib.types.path;
      default = ./index.mustache;
      description = "mustache template for the index";
    };
    repos = lib.mkOption {
      default = { };
      type = lib.types.listOf (lib.types.submodule ({ config, ... }: {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            example = "my-repo";
            description = "name of the repository";
          };
          root = lib.mkOption {
            type = lib.types.str;
            example = "/my-repo/";
            default = "/${config.name}/";
            description = "relative url of root directory";
          };
          revs = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "HEAD" ];
            example = [ "HEAD" "v1.1.0" ];
            description = "revisions to generate";
          };
          url = lib.mkOption {
            type = lib.types.str;
            default = "${config'.services.pgit.homeUrl}${config.root}.git";
            example = "https://github.com/myuser/myrepo.git";
          };
          description = lib.mkOption {
            type = lib.types.lines;
            description = "Description of the project";
          };
          cloneRev = lib.mkOption {
            type = lib.types.str;
            example = "v1";
            description = "revision to clone for pgit (probably latest)";
          };
          cloneHash = lib.mkOption {
            type = lib.types.str;
            example = "sha256-...";
            description = "hash of cloned project";
          };
          source = lib.mkOption {
            # type = ?
            default = pkgs.fetchgit {
              url = config.url;
              rev = config.cloneRev;
              hash = config.cloneHash;
              deepClone = true;
            };
          };
        };
      }));
      example = {
        dotfiles = {
          name = "dotfiles";
          description = "my dotfiles";
          cloneRev = "v1";
          cloneHash = "sha256-...";
        };
      };
    };
  };

  config = lib.mkIf config.services.pgit.enable {
    environment.etc."pgit".source = pkgs.symlinkJoin {
      name = "pgit-repos";
      paths = (lib.map (v: pkgs.stdenv.mkDerivation {
        pname = "pgit-${v.name}";
        version = "0";
        src = v.source;
        nativeBuildInputs = [ pkgs.git pkgs.pgit ];
        phases = [ "unpackPhase" "buildPhase" ];
        buildPhase = ''
          pgit --out $out/"${v.name}" \
               --root-relative "${v.root}" \
               --home-url "${config.services.pgit.homeUrl}" \
               --theme "${config.services.pgit.theme}" \
               --label "${v.name}" \
               --clone-url "${v.url}" \
               --desc "${v.description}" \
               --revs "${lib.join "," v.revs}"
        '';
      }) config.services.pgit.repos)
      ++ [(pkgs.stdenv.mkDerivation {
        pname = "pgit-index";
        version = "0";
        nativeBuildInputs = [ pkgs.mustache-go ];
        phases = [ "buildPhase" ];
        buildPhase = ''
          mkdir -p $out
          mustache ${config.services.pgit.index} < ${mustacheRepositories} > $out/index.html
        '';
      })];
      postBuild = ''
        find $out -name smol.css -exec cp "{}" $out/smol.css \;
      '';
    };
  };
}
