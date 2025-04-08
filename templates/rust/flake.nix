{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
  };

  outputs = inputs@{ flake-parts, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [ inputs.devshell.flakeModule ];
    systems = inputs.nixpkgs.lib.systems.flakeExposed;
    perSystem = { pkgs, ... }: {
      devshells.default = {
        motd = "";
        packages = with pkgs; [
          cargo
          rust-analyzer
          rustc
          rustfmt
        ];
      };
    };
  };
}
