{
  self,
  ...
}:
{
  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" "fingolfin" (
    { pkgs, ... }:
    {
      imports = with self.modules.nixos; [
        dictionary
        murrayle23
        sshfs
        wsl
      ];

      programs.ssh.startAgent = true;

      environment.sessionVariables.TERM = "alacritty-direct";
      environment.wordlist.enable = true;

      programs.zsh.enable = true;
      users.defaultUserShell = pkgs.zsh;

      time.timeZone = "America/New_York";
      system.stateVersion = "24.05";
    }
  );
}
