rec {
  opacity = 0.9;
  font = import ../../module/font/iosevka;
  theme = import ../../module/theme/generated/woodland;
  git-email = "69653100+amusingimpala75@users.noreply.github.com";
  git-username = "amusingimpala75";
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
