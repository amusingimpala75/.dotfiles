{
  flake.modules.homeManager.radicle =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.radicle-desktop ];
      programs.radicle = {
        enable = true;
        # Most of these are just the defaults
        settings = {
          "publicExplorer" = "https://app.radicle.xyz/nodes/$host/$rid$path";
          "preferredSeeds" = [
            "z6MkrLMMsiPWUcNPHcRajuMi9mDfYckSoJyPwwnknocNYPm7@iris.radicle.xyz:8776"
            "z6MkrLMMsiPWUcNPHcRajuMi9mDfYckSoJyPwwnknocNYPm7@irisradizskwweumpydlj4oammoshkxxjur3ztcmo7cou5emc6s5lfid.onion:8776"
            "z6Mkmqogy2qEM2ummccUthFEaaHvyYmYBYh3dbe9W4ebScxo@rosa.radicle.xyz:8776"
            "z6Mkmqogy2qEM2ummccUthFEaaHvyYmYBYh3dbe9W4ebScxo@rosarad5bxgdlgjnzzjygnsxrwxmoaj4vn7xinlstwglxvyt64jlnhyd.onion:8776"
          ];
          "web" = {
            "pinned" = {
              "repositories" = [ ];
            };
          };
          "cli" = {
            "hints" = true;
          };
          "node" = {
            "listen" = [ ];
            "peers" = {
              "type" = "dynamic";
            };
            "connect" = [ ];
            "externalAddresses" = [ ];
            "network" = "main";
            "log" = "INFO";
            "relay" = "auto";
            "limits" = {
              "routingMaxSize" = 1000;
              "routingMaxAge" = 604800;
              "gossipMaxAge" = 1209600;
              "fetchConcurrency" = 1;
              "maxOpenFiles" = 4096;
              "rate" = {
                "inbound" = {
                  "fillRate" = 5.0;
                  "capacity" = 1024;
                };
                "outbound" = {
                  "fillRate" = 10.0;
                  "capacity" = 2048;
                };
              };
              "connection" = {
                "inbound" = 128;
                "outbound" = 16;
              };
              "fetchPackReceive" = "500.0 MiB";
            };
            "workers" = 8;
            "seedingPolicy" = {
              "default" = "block";
            };
          };
        };
      };
    };
}
