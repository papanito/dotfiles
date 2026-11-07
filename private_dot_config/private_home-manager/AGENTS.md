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
- `llm-agents` input (github:numtide/llm-agents.nix) provides AI agent tooling; wire via its `overlays.shared-nixpkgs` overlay in flake.nix so packages live at `pkgs.llm-agents.<name>` and inherit our nixpkgs config. AI entries in home.nix (opencode2 = OpenCode v2 line — note `opencode` in that repo is the old v1, qwen-code, antigravity-cli, rtk, since 2026-11-07) come from there and are auto-updated by upstream daily — run `nix flake lock --update-input llm-agents` to pick up bumps. Upstream requires the nixpkgs it follows to be a reasonably current unstable. Note: direct `nix build github:...#<pkg>` outside the overlay currently fails on a `kandev` eval bug in llm-agents (`packages` output forces every package); the overlay path stays lazy and works.
- `keyguard` is NOT the nixpkgs package: `keyguard-latest` in home.nix installs the official prebuilt Linux release (nixpkgs lags upstream; a source bump would need regenerating Gradle deps.json). Bumping it = update `version`, `tag` in the release URL, and `sha256` (`nix hash file --sri`) together.
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