{
  inputs,
  ...
}:
{
  flake.modules = {
    homeManager.ssh = {
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

    nixos.ssh.services.openssh = {
      enable = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
      startWhenNeeded = true;
    };
  };
}
