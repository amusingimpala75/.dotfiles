{
  dotdir ? "~/.dotfiles",
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "install";
  text = builtins.readFile ./install.sh;
  meta.description = "Installation script for my dotfiles";
  runtimeEnv.DOTDIR = dotdir;
}
