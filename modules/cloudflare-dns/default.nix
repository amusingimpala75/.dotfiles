{
  lib,
  ...
}:
let
  module =
    {
      config,
      ...
    }:
    {
      options.cloudflare-dns =
        let
          domainEntry = lib.types.submodule {
            options = {
              A = lib.mkOption {
                description = "A DNS entries";
                default = [ ];
                example = [ "1.2.3.4" ];
                type = lib.types.listOf lib.types.str;
              };
              AAAA = lib.mkOption {
                description = "AAAA DNS entries";
                default = [ ];
                example = [ "1:2:3::4" ];
                type = lib.types.listOf lib.types.str;
              };
              CNAME = lib.mkOption {
                description = "CNAME DNS entries";
                default = { };
                example = {
                  "www" = "example.com";
                };
                type = lib.types.attrsOf lib.types.str;
              };
              MX = lib.mkOption {
                description = "MX DNS entries";
                default = [ ];
                type = lib.types.listOf lib.types.str;
              };
              TXT = lib.mkOption {
                description = "TXT DNS entries";
                default = [ ];
                example = [
                  {
                    name = "_acme-challenge.example.com";
                    content = "...";
                  }
                ];
                type = lib.types.listOf (lib.types.attrsOf lib.types.str);
              };
            };
          };
        in
        lib.mkOption {
          description = "cloudflare dns settings";
          default = { };
          type = lib.types.attrsOf domainEntry;
        };

      config.perSystem =
        {
          pkgs,
          ...
        }:
        {
          packages.write-cloudflare-dns = pkgs.python3Packages.buildPythonApplication {
            name = "write-cloudflare-dns";
            version = "0.1.0";

            src = ./write-cloudflare-dns.py;

            dontUnpack = true;
            format = "other";

            nativeBuildInputs = [ pkgs.makeWrapper ];

            installPhase =
              let
                python = pkgs.python3.withPackages (pp: [ pp.cloudflare ]);
              in
              ''
                install -Dm644 $src \
                  $out/${pkgs.python3Packages.python.sitePackages}/write-cloudflare-dns.py

                makeWrapper ${lib.getExe python} $out/bin/write-cloudflare-dns \
                  --add-flags "$out/${pkgs.python3Packages.python.sitePackages}/write-cloudflare-dns.py" \
                  --set CLOUDFLARE_NEW_DNS_SETTINGS "${
                    pkgs.writeTextFile {
                      name = "cloudflare-new-dns-settings";
                      text = builtins.toJSON config.cloudflare-dns;
                    }
                  }"
              '';
          };
        };
    };
in
{
  imports = [ module ];

  flake.modules.homeManager.cloudflare-manager.sops.secrets."cloudflare_dns_api_token" = { };
  flake.flakeModules.cloudflare-dns = module;
}
