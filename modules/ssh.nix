{
  inputs,
  ...
}:
{
  flake.modules.homeManager.ssh = {
    imports = [
      "${inputs.home-manager}/modules/programs/ssh.nix"
    ];

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        AddKeysToAgent = "yes";
      };
      settings."research" = {
        HostName = "10.37.104.75";
        User = "murrayle23";
      };
    };
  };
}
