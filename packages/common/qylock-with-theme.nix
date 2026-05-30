{
  fetchFromGitHub,
  stdenv,

  theme ? "pixel-hollowknight",
  hash ? "sha256-1At9ffKV46lAOYn0ksyHPIzn8FUsHJfKuHcw4ep6vSs=",
  ...
}:
stdenv.mkDerivation {
  name = "sddm-theme-${theme}";
  src = fetchFromGitHub {
    owner = "Darkkal44";
    repo = "qylock";
    # [NOTE] when updating don't forget to update the
    # default hash above
    rev = "3ecb79f621d5bfc2fbc6bfd37c3b12f0214601ac";
    inherit hash;
    sparseCheckout = [
      "themes/${theme}"
    ];
  };

  installPhase = ''
    mkdir -p "$out/share/sddm/themes/${theme}"
    cp -r "themes/${theme}/." "$out/share/sddm-themes/${theme}"
  '';
}
