{
  fetchFromGitHub,
  melpaBuild,
  ...
}:
let
  version = "0.2.0";
in
melpaBuild {
  pname = "discourse";
  inherit version;
  src = fetchFromGitHub {
    owner = "glenneth1";
    repo = "discourse.el";
    tag = "v${version}";
    hash = "sha256-XmPYfvMJqvlrFLQZfDSc5a5pWUbSDKDs8Q/b+UxNl9g=";
  };
}
