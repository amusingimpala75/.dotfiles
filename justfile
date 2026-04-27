_ := "just-ts-mode is dumb,
and will indent the later stuff
if this isn't here /shrug"

update-bleeding:
    nix flake update nixpkgs-bleeding nix-index-database

update:
    nix flake update
