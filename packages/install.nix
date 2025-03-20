{
  scriptWrapper,
  dotdir ? "~/.dotfiles",
  ...
}:
(scriptWrapper "install" [ ]).overrideAttrs (prev: {
  postBuild = prev.postBuild ++ " --set DOTDIR ${dotdir}";
})
