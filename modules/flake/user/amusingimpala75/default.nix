{
  flake.modules.nixos.amusingimpala75 =
    {
      pkgs,
      ...
    }:
    {
      users.mutableUsers = true;
      users.users.amusingimpala75 = {
        shell = pkgs.zsh;
        # Change this after installation
        initialPassword = "password";
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        packages = [
          pkgs.firefox
        ];
      };
    };
}
