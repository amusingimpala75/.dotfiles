{
  inputs,
  ...
}:
{
  flake.modules.nixos.wsl =
    {
      pkgs,
      ...
    }:
    {
      imports = [ inputs.nixos-wsl.nixosModules.default ];
      wsl.enable = true;
      wsl.startMenuLaunchers = true;
      systemd.services."wsl-mnt-guard" = {
        overrideStrategy = "asDropin";
        unitConfig.ConditionPathIsMountPoint = "/mnt/wsl";
        serviceConfig = {
          ExecStart = [
            ""
            "${pkgs.coreutils}/bin/true"
          ];
          ExecStop = [
            ""
            "-${pkgs.util-linux}/bin/mount --make-rslave /mnt/wsl"
          ];
        };
      };
    };

  flake.modules.homeManager.wsl =
    {
      config,
      lib,
      ...
    }:
    {
      options.wsl = {
        username = lib.mkOption {
          type = lib.types.str;
          example = "johndoe28";
          description = "username of the windows user (i.e. C:\Users\<username>)";
        };
        userFile = lib.mkOption {
          description = "list of files to copy over to Windows";
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                source = lib.mkOption {
                  description = "path to the file";
                  default = null;
                  type = lib.types.nullOr lib.types.path;
                };
                text = lib.mkOption {
                  description = "contents of the file";
                  default = null;
                  type = lib.types.nullOr lib.types.lines;
                };
              };
            }
          );
        };
      };
      config.home.activation.wslUserFiles =
        config.wsl.userFile
        |> lib.concatMapAttrsStringSep "\n" (
          name: val:
          let
            path = "/mnt/c/Users/${config.wsl.username}/${name}";
          in
          ''
            mkdir -p "$(dirname ${path})"
            rm -f "${path}"
          ''
          + (
            if val.source != null then
              ''
                cp "${val.source}" "${path}"
              ''
            else
              ''
                cat > "${path}" << EOF
                ${val.text}
                EOF
              ''
          )
        )
        |> lib.hm.dag.entryAfter [ "onFilesChange" ];
    };

  flake-file.inputs.nixos-wsl = {
    url = "github:nix-community/NixOS-WSL";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
