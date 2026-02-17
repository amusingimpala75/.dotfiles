final: prev: {
  get-win-sid = final.callPackage ../packages/get-win-sid.nix { };
  wallp = final.callPackage ../packages/wallp.nix { };
}
