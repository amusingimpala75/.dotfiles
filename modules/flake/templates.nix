let
  base = ../../templates;
in
{
  flake.templates = builtins.mapAttrs (key: _: {
    path = base + "/" + key;
    inherit (import "${base}/${key}/flake.nix") description;
  }) (builtins.readDir base);
}
