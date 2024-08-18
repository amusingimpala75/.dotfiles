{ userSettings, ... }:
{
  imports = [ userSettings.font.module ];
  fonts.fontconfig.enable = true;
}