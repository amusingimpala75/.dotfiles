{
  lib,
  ...
}:
{
  imports = [
    ./jujutsu.nix
    ./git.nix
  ];

  options.my.vcs = {
    email = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      example = "foo@bar.com";
      description = "Email to use for git";
    };
    username = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      example = "johndoe";
      description = "Git username";
    };
  };
}
