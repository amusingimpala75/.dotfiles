{
  # [TODO] In theory this should be covered by
  # nix-darwin#1452, but we'll see how long it takes
  flake.modules.darwin.user-applications =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      system.activationScripts =
        (
          config.users.users
          |> (lib.filterAttrs (_: { gid, ... }: gid != 350)) # Filter out _nixbld#
          |> (lib.mapAttrs' (
            _: user:
            let
              inherit (user) name home packages;
              directory = "${home}/Applications/Nix Apps";
              env = pkgs.buildEnv {
                name = "${name}-applications";
                paths = packages;
                pathsToLink = [ "/Applications" ];
              };
            in
            lib.nameValuePair "${name}-applications" {
              text = ''
                echo "setting up ${directory}..."
                rm -rf "${directory}"
                mkdir -p "${directory}"
                chown "${name}" "${directory}"
                chmod u+w "${directory}"
                ${lib.getExe pkgs.rsync} \
                  --recursive \
                  --checksum \
                  --perms \
                  --links \
                  --copy-unsafe-links \
                  --specials \
                  --delete \
                  --chmod=u+w \
                  --copy-as "${name}" \
                  --no-group \
                  ${env}/Applications/ "${directory}/"

                sudo --user "${name}" find "${directory}" -type d -maxdepth 1 -name "*.app" -exec /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister "{}" \;

                # /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister "${directory}/*.app"
              '';
            }
          ))
        )
        // {
          extraActivation.text = lib.strings.join "\n" (
            (builtins.attrValues config.users.users)
            |> builtins.filter ({ gid, ... }: gid != 350)
            |> map ({ name, ... }: config.system.activationScripts."${name}-applications".source)
          );
        };
    };
}
