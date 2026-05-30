{
  flake.overlays.fix-powermanagement = final: prev: {
    darwin = prev.darwin.overrideScope (
      dfinal: dprev: {
        PowerManagement = dprev.PowerManagement.overrideAttrs (old: {
          xcodeHash = "sha256-06rCxqBUrYqBY7BDZ6s/vSoviUAmIbsQP1pfrvR2Gpk=";
        });
      }
    );
  };
}
