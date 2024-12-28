self: super:
let
  version = "1.0.0";
  url = "https://release.files.ghostty.org/${version}/Ghostty.dmg";
  stdenv = super.stdenv;
in {
  ghostty-bin = stdenv.mkDerivation {
    version = version;
    pname = "Ghostty";

    outputs = [ "out" "terminfo" "shell_integration" ];

    buildInputs = [ super.pkgs._7zz ];
    sourceRoot = ".";
    phases = [ "unpackPhase" "installPhase" ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications
      cp -r Ghostty.app $out/Applications/

      runHook postInstall
    '';

    postInstall = ''
      terminfo_src=${
        if stdenv.hostPlatform.isDarwin
        then ''"$out/Applications/Ghostty.app/Contents/Resources/terminfo"''
        else "$out/share/terminfo"
      }

      mkdir -p "$out/nix-support"

      mkdir -p "$terminfo/share"
      mv "$terminfo_src" "$terminfo/share/terminfo"
      ln -sf "$terminfo/share/terminfo" "$terminfo_src"
      echo "$terminfo" >> "$out/nix-support/propagated-user-env-packages"

      mkdir -p "$shell_integration"
      mv "$out/Applications/Ghostty.app/Contents/Resources/ghostty/shell-integration" "$shell_integration/shell-integration"
      ln -sf "$shell_integration/shell-integration" "$out/Applications/Ghostty.app/Contents/Resources/ghostty/shell-integration"
      echo "$shell_integration" >> "$out/nix-support/propagated-user-env-packages"
    '';

    src = super.fetchurl {
      url = url;
      name = "Ghostty.dmg";
      sha256 = "091f7a2b3f4160a16d7d52b2822124bb9d5714993815f62a7d70027984372652";
    };

    meta = {
      description = "Ghostty is a fast, feature-rich, and cross-platform terminal emulator that uses platform-native UI and GPU acceleration.";
      homepage = "https://ghostty.org";
    };
  };
}
