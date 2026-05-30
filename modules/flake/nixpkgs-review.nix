{
  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    {
      packages.nixpkgs-review = pkgs.symlinkJoin {
        name = "nixpkgs-review";
        paths = with pkgs; [
          glow
          nixpkgs-review
          nom
          self'.packages.delta
        ];
      };
    };
}
