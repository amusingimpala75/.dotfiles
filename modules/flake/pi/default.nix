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
      xdg.configFile."pi/agents/AGENTS.md".source = ./global-agents.md;
      home.sessionVariables.PI_CODING_AGENT_DIR = "~/.config/pi/agent";
    };
}
