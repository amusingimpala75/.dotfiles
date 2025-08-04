{ pkgs, ... }:
{
  colorschemes.base16 = {
    enable = true;
    colorscheme = "woodland";
  };
  plugins = {
    airline.enable = true;
    chadtree.enable = true;
    comment.enable = true;

    gitgutter.enable = true;
    gitgutter.grepPackage = pkgs.ripgrep;
    indent-blankline.enable = true;

    neoscroll.enable = true;
    nvim-autopairs.enable = true;
    nvim-surround.enable = true;
    oil.enable = true;
    smear-cursor.enable = true;
    telescope.enable = true;
    toggleterm.enable = true;
    web-devicons.enable = true;
  };
}
