{
  inputs,
  self,
  ...
}:
{
  flake.modules.homeManager.sops =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      sops = {
        age.keyFile =
          if pkgs.stdenv.isDarwin then
            "${config.home.homeDirectory}/Library/Application Support/sops/age/keys.txt"
          else
            "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        defaultSopsFile = "${self}/secrets/secrets.yaml";
      };
    };

  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
