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

  cloudflare-dns."amusingimpala.com" = {
    # GitHub's IPv4
    A = [
      "185.199.108.153"
      "185.199.109.153"
      "185.199.110.153"
      "185.199.111.153"
    ];
    # GitHub's IPv6
    AAAA = [
      "2606:50c0:8000::153"
      "2606:50c0:8001::153"
      "2606:50c0:8002::153"
      "2606:50c0:8003::153"
    ];
    CNAME = {
      "*" = "uixie.porkbun.com";
      "avogadrio" = "amusingimpala75.github.io";
      "memory" = "amusingimpala75.github.io";
      "www" = "amusingimpala75.github.io";
      "comp451" = "my-platform-36w.pages.dev";
    };
    MX = [
      "fwd1.porkbun.com"
      "fwd2.porkbun.com"
    ];
    TXT = [
      {
        name = "_acme-challenge";
        content = "\"p9at7-oulXa9RED2C8hnPPa1Vst4qI5XzDrzxCXcUbI\"";
      }
      {
        name = "_acme-challenge";
        content = "\"-uzX8sWHBQhNMW_q-A3w5nrh8vE59aCnhg0SFFKW6Kw\"";
      }
      {
        name = "";
        content = "\"v=spf1 include:_spf.porkbun.com ~all\"";
      }
    ];
  };

  flake.modules.homeManager.cloudflare-manager.sops.secrets."cloudflare_dns_api_token" = { };
  flake.flakeModules.cloudflare-dns = module;
}
