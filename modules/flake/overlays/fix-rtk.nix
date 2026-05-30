{
  flake.overlays.fix-rtk = final: prev: {
    rtk = prev.rtk.overrideAttrs (
      old:
      let
        version = "0.42.0";
        src = final.fetchFromGitHub {
          owner = "rtk-ai";
          repo = "rtk";
          rev = "v${version}";
          hash = "sha256-ZCDVS/AFljljMac+cAzQztYPQgvQrcEhKIHHRhkMsv8=";
        };
      in
      {
        inherit src version;
        cargoDeps = final.rustPlatform.fetchCargoVendor {
          inherit src;
          hash = "sha256-CFhKBzJc2/+gZDfHq7wxBWEbtHV8EF3OYa+t1b9aL8k=";
        };
      }
    );
  };
}
