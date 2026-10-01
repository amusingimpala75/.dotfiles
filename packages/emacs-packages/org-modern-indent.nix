{
  fetchFromGitHub,
  melpaBuild,
  ...
}:
melpaBuild (finalAttrs: {
  pname = "org-modern-indent";
  version = "0.5.3";
  src = fetchFromGitHub {
    owner = "jdtsmith";
    repo = "org-modern-indent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vQzYk5qejCBehpbxkMceOMsmeLyjnAstpezZw/ZR1jQ=";
  };
})
