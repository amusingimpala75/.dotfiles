{
  inputs,
  ...
}:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      treefmt.programs = {
        actionlint.enable = true;

        fnlfmt.enable = true;

        deadnix.enable = true;
        nixf-diagnose = {
          enable = true;
          # specifically because of builtins.getFlake in package-runner-matrix.nix
          ignore = [ "sema-primop-unknown" ];
        };
        nixfmt = {
          enable = true;
          package = pkgs.nixfmt-rs;
        };
        statix.enable = true;

        shellcheck.enable = true;
        shfmt = {
          enable = true;
          indent_size = 4;
        };
      };
    };

  flake-file.inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
