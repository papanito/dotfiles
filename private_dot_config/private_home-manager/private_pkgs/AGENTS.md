# Vendored packages

## Purpose

Nix expressions for packages that are not available in nixpkgs (upstream has no Nix packaging or lags badly). Each file defines and returns exactly one package; `home.nix` imports them and keeps the bindings that `home.packages` references.

## Ownership

- `keyguard.nix` — `keyguard-latest`: official prebuilt Keyguard Linux release (Bitwarden-compatible client). nixpkgs' source build lags upstream and needs Gradle deps.json regeneration, so this fetches the released tarball and patches the runtime (autoPatchelf, libdbus wrapper, `.Keyguard-wrapped.cfg` copy). Failure history lives in the file comments — read it before touching the install phase.
- `rwx.nix` — vncsmnl/rwx permissions/ownership TUI via `buildRustPackage` from the upstream release tag.

Note: the runtime target has unmanaged leftovers in `pkgs/` (`gemini-cli.nix`) and `modules/` (`development.nix`, with a `developemnt.nix` typo twin) — earlier WIP that is not in the chezmoi source and is not imported by `flake.nix`. Do not delete it, do not adopt its style (`{ pkgs ? import <nixpkgs> {} }:` default-arg pattern), and do not wire it in: upstream already provides gemini-cli as `gemini-cli-bin` via llm-agents.

## Local Contracts

- Each file is a `{ pkgs, lib }: <package>` function; `home.nix` imports it as `import ./pkgs/<file>.nix { inherit pkgs lib; }`. The binding names (`keyguard-latest`, `rwx`) are referenced in `home.packages` — keep them stable.
- Package-specific comments, hashes, and failure notes belong in the package file, not in `home.nix`.
- Bumping a package: change `version`/`rev` (and the URL for fetchurl), then recompute every fixed-output hash with the fakeHash two-step (`nix build`, paste each `got:` line). For `buildRustPackage` do **not** switch to `cargoLock.lockFile = "${src}/…"` — `importCargoLock` reads the file at eval time while `src` is only realized during the build.

## Work Guidance

- Adding a package: create `<name>.nix` here, add one import line to `home.nix`'s let block, one entry to its `home.packages` list.
- Hash iteration against the full home config is slow; prototype in a scratch flake in `/tmp/opencode` that imports the same nixpkgs pin and builds only this package, then port the final definition verbatim.

## Verification

- `LD_LIBRARY_PATH= nix-instantiate --parse private_dot_config/private_home-manager/private_pkgs/<file>.nix` per file.
- `home-manager switch --flake .#papanito` applies; identical derivatives stay cached across refactors, so a pure move rebuilds nothing.

## Child DOX Index

No child AGENTS.md files — one `.nix` file per vendored package.
