{
  family.fixed-pitch = "Victor Mono";
  family.variable-pitch = "Victor Mono";
  size = 16;
  module = { pkgs, ... }:
  {
    home.packages = [
      pkgs.victor-mono
    ];
  };
}
