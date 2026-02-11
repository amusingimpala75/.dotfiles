{
  darwin,
  ntfy-sh,
  screen-saver,

  lib,
  scriptWrapper,
  ...
}:
scriptWrapper {
  path = ./run-ntfy-when-done.sh;
  extraMeta = {
    description = "run application with screen saver but not sleeping, notify when done";
    mainProgram = "run-ntfy-when-done";
    platforms = lib.platforms.darwin; # TODO: linux support
  };
  deps = [
    darwin.PowerManagement # caffeinate
    ntfy-sh
    screen-saver
  ];
}
