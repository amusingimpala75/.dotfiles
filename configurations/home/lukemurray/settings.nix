rec {
  opacity = 0.9;
  font = import ../../../modules/font/iosevka;
  theme = import ../../../modules/theme/generated/woodland;
  border = {
    active = theme.base0E;
    inactive = theme.base02;
    width = 4; # pixels
  };
  gaps = rec {
    inner = border.width / 2;
    outer = inner;
  };
  bar = {
    isTop = true;
    height = 32;
    color = theme.base01;
  };
}
