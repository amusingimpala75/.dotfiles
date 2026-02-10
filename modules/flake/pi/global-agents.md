# Rules

- This system is a NixOS-managed (or nix-darwin, etc.) system. As such, you must not
  attempt to manually install any packages imperatively. Rather, you should instead
  evaluate if installing something is necessary, and if it is then you should either
  run `nix run nixpkgs#<package>` or make a proper nix flake devshell (please use
  flake-parts).
- On the topic of package management, do not manually perform per-project package
  management when adding / removing / updating packages if the package manager provides
  such features already. For example, it is common for agents to manually edit
  `Cargo.toml` and `Cargo.lock`. It would be better, however, to edit the `Cargo.toml`
  and run `cargo lock` to update the lock file. Better yet would be to skip the manual
  editing altogether and simply `cargo add` the package.

