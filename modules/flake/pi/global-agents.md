# Rules

- This system is a NixOS-managed (or nix-darwin, etc.) system. As such, you must not
  attempt to manually install any packages imperatively. Rather, you should instead
  evaluate if installing something is necessary, and if it is then you should either
  run `nix run nixpkgs#<package>` or make a proper nix flake devshell (please use
  flake-parts).
- On the topic of package management, do not manually edit lock files when adding
  packages. Rather, use the provided methods by the package manager to lock the input
  (like `cargo lock`).
