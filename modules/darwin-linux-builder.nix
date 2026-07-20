{
  inputs,
  ...
}:
{
  flake.modules.darwin.linux-builder = {
    imports = [ inputs.nix-rosetta-builder.darwinModules.default ];
    nix-rosetta-builder.onDemand = true;
    # For bootstrap, comment the above and uncomment this,
    # then rebuild with the above uncommented and this commented
    # [TODO] just set up a proper centralised build server lol
    # nix.linux-builder = {
    #   enable = true;
    #   ephemeral = true;
    # };
  };

  flake-file.inputs.nix-rosetta-builder = {
    url = "github:cpick/nix-rosetta-builder";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
