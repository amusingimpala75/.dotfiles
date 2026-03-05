_ := "just-ts-mode is dumb,
and will indent the later stuff
if this isn't here /shrug"

update-bleeding:
    nix flake update nixpkgs-bleeding zen-browser sops-nix nix-index-database llm-agents pi-extensions

update:
    nix flake update
