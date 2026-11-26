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
          record =
            recordType:
            lib.types.submodule {
              options = {
                content = lib.mkOption {
                  type = lib.types.str;
                  description = "DNS record value.";
                };
                ttl = lib.mkOption {
                  type = lib.types.ints.positive;
                  default = 1;
                  description = "TTL in seconds; 1 selects Cloudflare's automatic TTL.";
                };
              }
              //
                lib.optionalAttrs
                  (builtins.elem recordType [
                    "A"
                    "AAAA"
                    "CNAME"
                  ])
                  {
                    proxied = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      description = "Whether Cloudflare proxies this record.";
                    };
                  }
              // lib.optionalAttrs (recordType == "MX") {
                priority = lib.mkOption {
                  type = lib.types.ints.between 0 65535;
                  default = 10;
                  description = "MX priority (lower values are preferred).";
                };
              };
            };
          domainEntry = lib.types.attrsOf (
            lib.types.submodule {
              options = lib.genAttrs [ "A" "AAAA" "CNAME" "MX" "TXT" ] (
                recordType:
                lib.mkOption {
                  type = lib.types.listOf (record recordType);
                  default = [ ];
                  description = "${recordType} records at this relative name.";
                }
              );
            }
          );
        in
        lib.mkOption {
          description = "Cloudflare records keyed by zone, relative name (@ for apex), and type. Undeclared records in managed zones are deleted.";
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

  flake.modules.homeManager.cloudflare-manager =
    {
      config,
      ...
    }:
    {
      sops.secrets."cloudflare_dns_api_token" = { };
      home.sessionVariables.CLOUDFLARE_API_TOKEN_FILE =
        config.sops.secrets."cloudflare_dns_api_token".path;
    };
  flake.flakeModules.cloudflare-dns = module;
}
