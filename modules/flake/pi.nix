{
  inputs,
  ...
}:
{
  flake.modules.homeManager.pi =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [ inputs.llm-agents.overlays.default ];
      home.packages = [ pkgs.llm-agents.pi ];
    };
}
