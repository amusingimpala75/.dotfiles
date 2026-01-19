{
  scriptWrapper,
  dotdir ? "~/.dotfiles",
  ...
}:
(scriptWrapper "install" [ ]).overrideAttrs (prev: {
  postBuild = (if prev ? "postBuild" then prev.postBuild else "") + " --set DOTDIR ${dotdir}";
})
// {
  meta = {
    description = "Installation script for my dotfiles";
    mainProgram = "install";
  };
}
