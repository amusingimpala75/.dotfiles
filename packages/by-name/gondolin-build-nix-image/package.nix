{
  output ? ".cache/gondolin/nix-assets",

  coreutils,
  e2fsprogs,
  gondolin,
  lib,
  lz4,
  nix,
  python3,
  writeShellApplication,
  writeText,

  global-gitignore,
}:
let
  # [TODO] integrate with the rest of my config
  agent-gitconfig = writeText "agent-gitconfig" ''
    [core]
      excludesFile = /etc/gitignore

    [init]
      defaultBranch = "trunk"

    [push]
      autoSetupRemote = true

    [safe]
      directory = /workspace

    [author]
      email = "69653100+amusingimpala75@users.noreply.github.com"
      name = "Pi Coding Agent"

    [user]
      email = "69653100+amusingimpala75@users.noreply.github.com"
      name = "amusingimpala75"
  '';
  agent-jj-config = writeText "agent-jj-config" ''
    [git]
    private-commits = "visible_heads() | description('private:*')"
    sign-on-push = true

    [revsets]
    bookmark-advance-to = "@-"

    [user]
    email = "69653100+amusingimpala75@users.noreply.github.com"
    name = "Pi Coding Agent"

    [working-copy]
    eol-conversion = "input"
  '';
in
writeShellApplication {
  name = "gondolin-build-nix-image";

  runtimeInputs = [
    coreutils
    e2fsprogs
    gondolin
    lz4
    nix
    python3
  ];

  text =
    builtins.replaceStrings
      [
        "@output@"
        "@global-gitignore@"
        "@agent-gitconfig@"
        "@agent-jj-config@"
      ]
      [
        output
        global-gitignore.outPath
        agent-gitconfig.outPath
        agent-jj-config.outPath
      ]
      (builtins.readFile ./gondolin-build-nix-image.sh);

  passthru = { inherit output; };

  meta = {
    description = "Build a globally cached Gondolin image from a flake development shell";
    platforms = lib.platforms.all;
  };
}
