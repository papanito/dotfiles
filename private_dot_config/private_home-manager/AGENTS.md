# Home Manager Flake

## Purpose

Standalone Home Manager configuration for user `papanito`, managed as a Nix flake with custom service modules.

## Ownership

- Edited only in chezmoi source: `private_dot_config/private_home-manager/`
- Applied via `home-manager switch --flake .#papanito`
- Runtime target: `~/.config/home-manager/` (chezmoi-managed)

## Local Contracts

- Flake inputs are declared in `flake.nix`, destructured in `outputs`, and passed to modules via `extraSpecialArgs`
- Each service is a self-contained module in `private_modules/` (chezmoi `private_` prefix)
- Modules are added to the `modules` list in `flake.nix` `homeConfigurations."papanito"`
- Systemd user services follow the pattern in `llama-cpp.nix` / `watchman.nix` (Unit/Service/Install)

## Work Guidance

- Adding a flake input = 3 edits: `inputs`, `outputs` destructure, `extraSpecialArgs` (if the module needs it)
- New modules: create `private_modules/<name>.nix`, add to `modules` list
- The `private_` prefix on directories is mandatory for chezmoi

## Verification

- `nix-instantiate --parse flake.nix` (syntax check, needs `LD_LIBRARY_PATH` unset on NixOS)
- `nix flake check` for full flake validation
- `home-manager switch --flake .#papanito` to apply

## Child DOX Index

No child AGENTS.md files — modules are flat files, not durable sub-boundaries.