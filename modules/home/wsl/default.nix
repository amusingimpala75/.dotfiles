{
  config,
  lib,
  ...
}:
{
  imports = [
    ./wallp.nix
    ./wezterm.nix
  ];

  options.wsl = {
    enable = lib.mkEnableOption "if this is WSL";
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

  config = lib.mkIf config.wsl.enable {
    home.activation.wslUserFiles =
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
}
