{
  flake.modules.homeManager.sketchybar = {
    my.sketchybar.enable = true;
    programs.wallust.settings = {
      templates.fennel = {
        template = ./wallust/fennel.wallust;
        target = "~/.config/sketchybar/colors.fnl";
      };
      hooks.sketchybar = ''
        killall sketchybar
      '';
    };
  };
}
