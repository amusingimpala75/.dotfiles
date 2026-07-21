{
  darwin,
  ntfy-sh,
  screen-saver,

  lib,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "run-ntfy-when-done";
  text = builtins.readFile ./run-ntfy-when-done.sh;
  meta.description = "run application with screen saver but not sleeping, notify when done";
  meta.platforms = lib.platforms.darwin; # TODO: linux support
  runtimeInputs = [
    darwin.PowerManagement # caffeinate
    ntfy-sh
    screen-saver
  ];
}
