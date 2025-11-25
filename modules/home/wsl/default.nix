{
  config,
  lib,
  ...
}:
{
  imports = [ ./wallp.nix ./wezterm.nix ];

  options.wsl = {
    enable = (lib.mkEnableOption "if this is WSL") // {
      default = "" == (builtins.getEnv "WSL_DISTRO_NAME");
    };
    username = lib.mkOption {
      type = lib.types.str;
      example = "johndoe28";
      description = "username of the windows user (i.e. C:\Users\<username>)";
    };
    userFile = lib.mkOption {
      description = "list of files to copy over to Windows";
      type = lib.types.attrsOf (lib.types.submodule {
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
      });
    };
  };

  config = lib.mkIf config.wsl.enable {
    home.activation = builtins.mapAttrs (name: val: lib.hm.dag.entryAfter [ "writeBoundary" ] (''
      # Ensure enclosing folder exists
      mkdir -p /mnt/c/Users/${config.wsl.username}/$(dirname ${name})
      # Remove old copy (TODO: may want to back up to not destroy old if first time?)
      rm -f /mnt/c/Users/${config.wsl.username}/${name}
    '' + (if val.source != null then ''
      # Copy by source
      cp ${val.source} /mnt/c/Users/${config.wsl.username}/${name}
    '' else ''
      # Copy by value
      cat > /mnt/c/Users/${config.wsl.username}/${name} << EOF
      ${val.text}
      EOF
    ''))) config.wsl.userFile;
  };
}
