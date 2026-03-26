{
  inputs,
  ...
}:
let
  common-gc = {
    nix.gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
  };
  common-angrr = {
    services.angrr = {
      enable = true;
      period = "14d";
      settings = {
        profile-policies.system.keep-latest-n = 10;
        profile-policies.user.keep-latest-n = 10;
      };
    };
  };
in
{
  flake.modules = {
    darwin.store-garbage-collect = {
      imports = [
        inputs.angrr.darwinModules.angrr
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
        inputs.angrr.nixosModules.angrr
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
