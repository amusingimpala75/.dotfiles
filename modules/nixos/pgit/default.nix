{
  config,
  lib,
  pkgs,
  ...
}:
let
  config' = config;

  pgit = (pkgs.pgit.overrideAttrs (_: {
    version = "git+01-24-2026";
    src = pkgs.fetchFromGitHub {
      owner = "picosh";
      repo = "pgit";
      rev = "c251930645ab9ce98fe48d4839c7d0563ff004be";
      hash = "sha256-H2y22WotM2UmUXHJvgC1XR5i0pOKQIQRX9tALD47SCE=";
    };
  }));

  mustacheRepositories = pkgs.writeTextFile {
    name = "data.yaml";
    text = lib.strings.toJSON config.services.pgit;
  };

  updateScript = ''
    export PATH=${lib.makeBinPath [ pkgs.git pgit pkgs.mustache-go ]}:$PATH
    rm -rf /tmp/pgit /var/www/pgit
    mkdir -p /tmp/pgit /var/www/pgit
  '' + (lib.concatMapStringsSep "\n" (repo: ''
    cd /tmp/pgit/
    git init "${repo.name}"
    cd "${repo.name}"
    git remote add origin "${repo.url}"
  '' + (lib.concatMapStringsSep "\n" (rev: ''
    git fetch origin "${rev}"
  '') repo.revs) + ''
    git checkout "${builtins.elemAt repo.revs 0}"
    pgit --out /var/www/pgit/"${repo.name}" \
         --root-relative "${repo.root}" \
         --home-url "${config.services.pgit.homeUrl}" \
         --theme "${config.services.pgit.theme}" \
         --label "${repo.name}" \
         --clone-url "${repo.url}" \
         --desc "${repo.description}" \
         --revs "${lib.join "," repo.revs}"
  '') config.services.pgit.repos) + ''
    cd /var/www/pgit
    mustache ${config.services.pgit.index} < ${mustacheRepositories} > index.html
    find . -name smol.css -exec cp "{}" ./smol.css \; -quit
    find . -name main.css -exec cp "{}" ./main.css \; -quit
    find . -name vars.css -exec cp "{}" ./vars.css \; -quit

    rm -rf /tmp/pgit
  '';

  removePrefixes = prefixes: text: let
    prefix = prefixes.filter (p: lib.hasPrefix p text) prefixes;
  in if (builtins.length prefix) != 0
     then lib.removePrefix (builtins.elemAt 0 prefix) text
     else text;

  noProtocol = removePrefixes [ "https://" "http://" ];
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
    nginx = lib.mkEnableOption "pgit host with nginx";
    homeUrl = lib.mkOption {
      type = lib.types.str;
      example = "https://git.mydomain.com";
      description = "URL of the repositories's homepage";
      default = "${config.services.pgit.protocol}://${config.services.pgit.domain}";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      example = "git.mydomain.com";
    };
    protocol = lib.mkOption {
      type = lib.types.str;
      default = "https";
      example = "http";
    };
    index = lib.mkOption {
      type = lib.types.path;
      default = ./index.mustache;
      description = "mustache template for the index";
    };
    repos = lib.mkOption {
      default = { };
      type = lib.types.listOf (
        lib.types.submodule (
          { config, ... }:
          {
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
                example = [
                  "HEAD"
                  "v1.1.0"
                ];
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
            };
          }
        )
      );
      example = {
        dotfiles = {
          name = "dotfiles";
          description = "my dotfiles";
          revs = [ "master" ];
        };
      };
    };
  };

  config = lib.mkIf config.services.pgit.enable {
    system.activationScripts.pgit-setup.text = updateScript;
    services.nginx.virtualHosts."${config.services.pgit.domain}" = lib.mkIf config.services.pgit.nginx {
      root = "/var/www/pgit";
      locations."/" = { };
    };
  };
}
# Example nixos config:
# services.nginx.enable = true;
# services.pgit = {
#   enable = true;
#   nginx = true;
#   theme = "nord";
#   protocol = "http";
#   domain = "git.localhost";
#   repos = [
#     {
#       name = ".dotfiles";
#       description = "my dotfiles";
#       url = "https://github.com/amusingimpala75/.dotfiles.git";
#       revs = [ "master" ];
#     }
#   ];
# };
