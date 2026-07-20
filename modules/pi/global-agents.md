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

# Advice

These are a list of various things you should know about this setup to be able to operate
to the best of your ability, instead of sitting around, wasting tokens trying to figure
out why things are the way they are.

- I often use Jujutsu for my version control, so if git isn't behaving like you thought
  it may just be that the repo is using Jujutsu. If placed in a Jujutsu workspace, you
  are not to attempt to edit the other workspaces but should remain in the workspace
  in which you were started
- Every execution of the agent occurs in a sandboxed environment, which may be blocking
  the access of some files or directories. Specifically, files outside of the current
  working directory are not accessible, except for a whitelist depending on the agent
  setup. If you find yourself denied access to a file, please consider if the action
  can be done with minimal impedance a different way. If it is still not possible to be
  done that way, please prompt the user about potentially modifying the sandbox to be able
  to acess what is needed.
