{
  fetchFromGitHub,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation {
  name = "sddm-pixel-hollowknight";

  src = fetchFromGitHub {
    owner = "Darkkal44";
    repo = "qylock";
    rev = "e38389bf746dcfd67a907cbc2d36059db27d6817";
    hash = "sha256-8Sm96ghNO6dTwjXtsEzTPo4Ag+/XTAAp+TooSRIHTmo=";
  };

  outputs = [
    "out"
    "fonts"
  ];

  installPhase = ''
    mkdir -p $out/share/sddm/themes/pixel-hollowknight
    cp themes/pixel-hollowknight/{theme.conf,Main.qml,BackgroundVideo.qml,bg.mp4,metadata.desktop} $out/share/sddm/themes/pixel-hollowknight

    mkdir -p $fonts/share/fonts/truetype
    cp themes/pixel-hollowknight/font/PixelifySans-Bold.ttf $fonts/share/fonts/truetype/
  '';
}
