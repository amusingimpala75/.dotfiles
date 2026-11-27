{
  flake.wrappers = {
    bat =
      {
        pkgs,
        wlib,
        ...
      }:
      {
        imports = [ wlib.wrapperModules.bat ];

        settings = {
          theme = "base16";
          wrap = "never";
        };

        package = pkgs.symlinkJoin {
          name = "bat";
          paths = [
            pkgs.bat
          ]
          ++ (with pkgs.bat-extras; [
            batman
            batdiff
            batpipe
            batgrep
            (prettybat.override {
              withClangTools = false;
              withRustFmt = false;
            })
          ]);
          meta.mainProgram = "bat";
        };
      };
  };
}
