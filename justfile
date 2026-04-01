_ := "just-ts-mode is dumb,
and will indent the later stuff
if this isn't here /shrug"

update-bleeding:
    nix flake update nixpkgs-bleeding sops-nix nix-index-database llm-agents pi-extensions

update:
    nix flake update
