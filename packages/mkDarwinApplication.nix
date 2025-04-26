{
  icnsify,
  lib,
  stdenvNoCC,
  writeText,
  ...
}: {
  package,
  exeName,
  appName ? exeName,
  img ? null,
}:
let
  executable = "${package}/bin/${exeName}";
  infoPlist = writeText "Info.plist" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    <key>CFBundleExecutable</key>
    <string>${builtins.baseNameOf executable}</string>
    <key>CFBundleIconFile</key>
    <string>shortcut.icns</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    </dict>
    </plist>
  '';
in stdenvNoCC.mkDerivation {
  inherit (package) name;

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/Applications/${appName}.app/Contents/MacOS
    mkdir -p $out/Applications/${appName}.app/Contents/Resources

    echo ${img}

    ${icnsify}/bin/icnsify --output $out/Applications/${appName}.app/Contents/Resources/${appName}.icns ${img}

    ln -s ${executable} $out/Applications/${appName}.app/Contents/MacOS/${exeName}

    cp ${infoPlist} $out/Applications/${appName}.app/Contents/Info.plist
  '';

  meta.platforms = lib.platforms.darwin;
}
