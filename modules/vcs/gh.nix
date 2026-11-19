{
  inputs,
  ...
}:
{
  flake.modules.homeManager.gh =
    {
      pkgs,
      ...
    }:
    {
      imports = [
        "${inputs.home-manager}/modules/programs/gh.nix"
      ];

      programs.gh = {
        enable = true;
        settings = {
          git_protocol = "ssh";
          telemetry = "disabled";
          version = "1";
        };
        extensions = with pkgs; [
          gh-actions-lock
          gh-contribs
          gh-dash
          gh-enhance
          gh-notify
          gh-skyline
          gh-stack
          gh-yule-log
        ];
      };
    };
}
