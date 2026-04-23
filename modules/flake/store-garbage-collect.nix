let
  common-gc = {
    nix.gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };
  common-angrr = {
    services.angrr = {
      enable = true;
      settings = {
        keep-since = "7d";
        keep-latest-n = 10;
      };
    };
  };
in
{
  flake.modules = {
    darwin.store-garbage-collect = {
      imports = [
        common-angrr
        common-gc
      ];
      nix.gc.interval = {
        Weekday = 7;
        Hour = 3;
        Minute = 15;
      };
    };
    homeManager.store-garbage-collect = {
      imports = [ common-gc ];
      nix.gc = {
        persistent = true;
        dates = "weekly";
      };
    };
    nixos.store-garbage-collect = {
      imports = [
        common-angrr
        common-gc
      ];
      nix.gc = {
        persistent = true;
        dates = "weekly";
      };
    };
  };
}
