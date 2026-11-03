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
- `nixpkgs.config` set in `flake.nix` is IGNORED by home-manager's internal nixpkgs re-import; put nixpkgs config (allowUnfree, problems.handlers…) in `home.nix` as the `nixpkgs.config` module option where it actually applies
- `problems.handlers.<pkg>.broken = "warn"` only permits EVALUATION of broken deps; it cannot un-break a genuinely failing build (e.g. azure-cli/fabric vs invoke ≥3, removed 2026-11-03 until upstream fixes)
- GNOME extension attrs come from the nixpkgs scrape of extensions.gnome.org filtered by the packaged shell versions (49/50/51): extensions lacking current shell support (e.g. `topiconsfix`, `campeek`) drop out of the set and break the build — replace with maintained successors (`tray-icons-reloaded`) or comment out with a dated note
- Usecase-driven debug: `nix eval --impure --expr 'builtins.getFlake "/home/papanito/.config/home-manager" …'` to probe attrs before editing

## Verification

- `nix-instantiate --parse flake.nix` (syntax check, needs `LD_LIBRARY_PATH` unset on NixOS)
- `nix flake check` for full flake validation
- `home-manager switch --flake .#papanito` to apply (or just `ca` — full chezmoi apply triggers it via post script; the single-target `chezmoi apply ~/.config/home-manager/<file>` variants do too)
- `home-manager generations | head -3` to confirm a new generation is current

## Child DOX Index

No child AGENTS.md files — modules are flat files, not durable sub-boundaries.