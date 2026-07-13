{
  lib,
  pkgs,
  ...
}:
{
  home.activation.load-settings = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter [ "setDarwinDefaults" ] ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activatesettings -u
    ''
  );
}
