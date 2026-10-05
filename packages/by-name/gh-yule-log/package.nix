{
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
}:

buildGoModule (finalAttrs: {
  pname = "gh-yule-log";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "leereilly";
    repo = "gh-yule-log";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/01aNK76TK2cl9xdibYiZaWMzNtoNS35OCK3gPbVPDs=";
  };

  vendorHash = "sha256-8UprJXRLFO3giWAm8k+vbNz7HPYwKW7cD36qc3hEkzE=";

  __structuredAttrs = true;
  strictDeps = true;

  postPatch = ''
    substituteInPlace main.go \
      --replace-fail 'exec.Command("git", args...)' 'exec.Command("${lib.getExe git}", args...)'
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "GitHub CLI extension with an animated Yule log and Git commit ticker";
    homepage = "https://github.com/leereilly/gh-yule-log";
    license = lib.licenses.mit;
    mainProgram = "gh-yule-log";
  };
})
