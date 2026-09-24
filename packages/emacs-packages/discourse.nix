{
  fetchFromGitHub,
  melpaBuild,
  ...
}:
melpaBuild (finalAttrs: {
  pname = "discourse";
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "glenneth1";
    repo = "discourse.el";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XmPYfvMJqvlrFLQZfDSc5a5pWUbSDKDs8Q/b+UxNl9g=";
  };
})
