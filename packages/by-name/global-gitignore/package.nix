{
  lib,
  writeText,
  ...
}:
(writeText "global-gitignore" ''
  *~
  **/.DS_Store
  .direnv
  .envrc
  /result
  .env
'').overrideAttrs
  (_: {
    meta.platforms = lib.platforms.all;
  })
