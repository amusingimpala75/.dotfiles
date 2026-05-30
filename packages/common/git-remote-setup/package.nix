{
  # ngl the fact all of the dependencies
  # start with 'g' is kinda great
  gettext,
  git,
  gnugrep,
  gum,
  writeShellApplication,
}:
writeShellApplication {
  name = "git-remote-setup";
  text = builtins.readFile ./git-remote-setup.sh;
  runtimeInputs = [
    gettext
    git
    gnugrep
    gum
  ];
  runtimeEnv.GIT_REMOTE_SETUP_PROVIDERS = ./providers.txt;
  meta.description = "setup multiple push-urls for a repo";
}
