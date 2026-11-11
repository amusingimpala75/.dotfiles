{
  flake.wrappers.nixpkgs-review =
    {
      pkgs,
      wlib,
      ...
    }:
    {
      imports = [ wlib.modules.default ];
      config = {
        package = pkgs.nixpkgs-reviewFull.override (old: {
          nixpkgs-review = old.nixpkgs-review.override {
            delta = pkgs.custom-delta;
          };
        });
        appendFlag = [
          [
            "--systems"
            "all"
          ]
        ];
      };
    };
}
