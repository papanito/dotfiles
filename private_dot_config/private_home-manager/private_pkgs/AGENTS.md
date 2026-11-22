# Vendored packages

## Purpose

Nix expressions for packages absent from nixpkgs or lagging badly. Each file defines exactly one package; `home.nix` imports them.

## Ownership

- `keyguard.nix` — `keyguard-latest`: official prebuilt Keyguard Linux release, patched in the install phase.
- `rwx.nix` — vncsmnl/rwx TUI via `buildRustPackage`.

The runtime target also holds unmanaged leftovers (`pkgs/gemini-cli.nix`, `modules/development.nix`, `modules/developemnt.nix`). They are not imported; do not delete, adopt, or wire them in.

## Local Contracts

- Each file is a `{ pkgs, lib }: <package>` function; `home.nix` imports it as `import ./pkgs/<file>.nix { inherit pkgs lib; }`.
- Binding names (`keyguard-latest`, `rwx`) are referenced in `home.packages`; keep them stable.
- Package-specific hashes and notes live in the package file, not in `home.nix`.
- Bumping: update `version`/`rev` (and the URL for fetchurl), then recompute every fixed-output hash with the fakeHash two-step (`nix build`, paste each `got:` line).
- For `buildRustPackage` do not use `cargoLock.lockFile = "${src}/…"`: `importCargoLock` reads at eval time.

## Work Guidance

- Adding a package: create `<name>.nix`, add one import line to `home.nix`'s let block, one entry to `home.packages`.
- Prototype hashes in a scratch flake in `/tmp/opencode` with the same nixpkgs pin, then port the definition verbatim.

## Verification

- `LD_LIBRARY_PATH= nix-instantiate --parse private_dot_config/private_home-manager/private_pkgs/<file>.nix`
- `home-manager switch --flake .#papanito`

## Child DOX Index

No child AGENTS.md files — one `.nix` file per vendored package.
