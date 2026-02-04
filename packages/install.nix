{
  scriptWrapper,
  dotdir ? "~/.dotfiles",
  ...
}:
(scriptWrapper {
  path = ./install.sh;
  extraMeta = {
    description = "Installation script for my dotfiles";
  };
}).overrideAttrs
  (prev: {
    postBuild = (if prev ? "postBuild" then prev.postBuild else "") + "--set DOTDIR ${dotdir}";
  })
