{
  inputs,
  ...
}:
{
  flake.modules.homeManager.tangled =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [
        inputs.tg.packages.${pkgs.stdenv.hostPlatform.system}.tg
      ];
    };

  flake-file.inputs.tg.url = "git+https://tangled.org/did:plc:g5uweck3xar3m745g43giuhr";
}
