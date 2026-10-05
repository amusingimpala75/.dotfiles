{
  flake.modules.homeManager.ssh = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        AddKeysToAgent = "yes";
      };
    };
  };
}
