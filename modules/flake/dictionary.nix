{
  self,
  ...
}:
let
  common =
    {
      pkgs,
      ...
    }:
    {
      services.dictd = {
        enable = true;
        DBs = [ pkgs.webster-1913-dictd ];
      };
    };
in
{
  flake.modules.nixos.dictionary = common;

  flake.modules.darwin.dictionary = {
    imports = [
      self.darwinModules.dictd
      common
    ];
  };

  flake.darwinModules.dictd =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.services.dictd = {
        enable = lib.mkEnableOption "DICT.org dictionary server";
        DBs = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = with pkgs.dictdDBs; [
            wiktionary
            wordnet
          ];
        };
      };
      config =
        let
          dictdb = pkgs.dictDBCollector {
            dictlist = map (x: {
              name = x.name;
              filename = x;
            }) config.services.dictd.DBs;
          };
        in
        lib.mkIf config.services.dictd.enable {
          environment.systemPackages = [ pkgs.dict ];
          environment.etc."dict.conf".text = ''
            server localhost
          '';
          launchd.daemons.dictd = {
            command = "${pkgs.dict}/sbin/dictd -c ${dictdb}/share/dictd/dictd.conf --locale en_US.UTF-8";
            serviceConfig = {
              KeepAlive = true;
              RunAtLoad = true;
            };
          };
        };
    };
}
