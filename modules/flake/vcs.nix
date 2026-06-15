{
  flake.modules.homeManager.vcs =
    {
      lib,
      ...
    }:
    {
      options.vcs = {
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
    };

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.global-gitignore = pkgs.writeText "global-gitignore" ''
        *~
        **/.DS_Store
        .direnv
        .envrc
        .env
      '';
    };
}
