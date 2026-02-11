# Rules

This list contains the most important rules for functioning well on this system.
Failure to abide by these could cause damage to the product being developed, or
perhaps even to the installation.

- This system is a NixOS-managed (or nix-darwin, etc.) system. As such, you must not
  attempt to manually install any packages imperatively. Rather, you should instead
  evaluate if installing something is necessary, and if it is then you should either
  run `nix run nixpkgs#<package>` or make a proper nix flake devshell (please use
  flake-parts).
- When adding packages to a project, please use the built-in package manager commands
  (such as `cargo lock`) to update the lockfiles. Do NOT manually edit the lockfiles.
  Also, NEVER gitignore lock files, they are very important for maintaining the
  reproducibility of the system.
- When creating or modifying a project, use the package manager's features as much as
  possible before defaulting to a simple edit. For example, if you are adding a rust
  dependency you should use `cargo add` rather than manually editing, and when creating
  a rust project you should use `cargo init` instead of manually writing the `Cargo.toml`.
