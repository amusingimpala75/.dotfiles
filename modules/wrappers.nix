{
  inputs,
  lib,
  self,
  ...
}:
{
  imports = [ inputs.wrappers.flakeModules.wrappers ];

  perSystem.wrappers.control_type = "build";

  flake.overlays.wrappers = final: prev: {
    local = prev.local.overrideScope (
      _: _:
      self.wrappers
      |> lib.filterAttrs (
        k: v: !lib.hasSuffix "-wrapper" k && lib.meta.availableOn prev.stdenv.hostPlatform v
      )
      |> lib.mapAttrs' (
        k: v:
        lib.nameValuePair "custom-${k}" (
          (v.eval { pkgs = final; }).config.wrapper.overrideAttrs (old: {
            meta =
              (lib.optionalAttrs (old ? meta) old.meta)
              // (lib.optionalAttrs (v ? meta && v.meta ? platforms) {
                inherit (v.meta) platforms;
              });
          })
        )
      )
    );
  };

  flake-file.inputs.wrappers = {
    url = "github:nix-community/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
