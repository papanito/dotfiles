# Home Manager Flake

## Purpose

Standalone Home Manager configuration for user `papanito`, managed as a Nix flake with custom service modules.

## Ownership

- Edited only in chezmoi source: `private_dot_config/private_home-manager/`
- Applied via `home-manager switch --flake .#papanito`
- Runtime target: `~/.config/home-manager/` (chezmoi-managed)

## Local Contracts

- Flake inputs are declared in `flake.nix`, destructured in `outputs`, and passed to modules via `extraSpecialArgs`
- `nixpkgs` is pinned to the exact rev in `/etc/nixos/flake.lock` (currently nixos-26.05 `c56a87d`), and `home-manager` tracks `release-26.05` like the system flake does. Not cosmetic: the GNOME session exports `GI_TYPELIB_PATH` from the **system** glib, so a home-manager `gjs` from a different nixpkgs loads a foreign libgio and aborts on `import Gio` (duplicate `GOutputStream`/`GPollableOutputStream` GTypes) — that produced a core dump on every shell start. Same rev ⇒ same store path ⇒ same gjs as the shell. Bump the rev here and in `/etc/nixos` together; never unpin the global nixpkgs for a single input.
- SSH agent is Keyguard's built-in agent (`ssh_agent` key in `~/.local/share/keyguard/settings`), socket `$XDG_RUNTIME_DIR/keyguard-ssh-agent.sock`. `home.nix` exports it as `SSH_AUTH_SOCK` through `systemd.user.sessionVariables`, because environment.d is what graphical logins read; `home.sessionVariables` only feeds `/etc/profile.d/hm-session-vars.sh` (login shells). The path is literal: environment.d performs no variable expansion and `home.uid` evaluates to null here. Bitwarden desktop must stay out of the session — at every start it re-injects `/home/papanito/.bitwarden-ssh-agent.sock` via `systemctl --user set-environment`, overriding environment.d for every process started afterwards. Hence the chezmoi stub `private_dot_config/autostart/bitwarden.desktop` (`Hidden=true`) plus its in-app "start on login" and SSH-agent toggles off, and the chezmoi-root shell startup files (`private_dot_zshenv.tmpl`, `private_dot_zshrc.tmpl`, `private_dot_bashrc.tmpl`) export the same socket so terminals never inherit a stale session value.
- User-facing desktop apps (guake, flameshot, keyguard, GNOME extensions) are installed here in `home.packages`, not in the host's `hosts/<host>/packages.nix` — that list is for system-level tooling. guake is spread over three files: package in `home.nix`, dconf in `private_modules/gnome.nix`, login entry in `private_dot_config/autostart/guake.desktop`.
- Each service is a self-contained module in `private_modules/` (chezmoi `private_` prefix)
- Modules are added to the `modules` list in `flake.nix` `homeConfigurations."papanito"`
- Systemd user services follow the pattern in `llama-cpp.nix` / `watchman.nix` (Unit/Service/Install)

## Work Guidance

- Adding a flake input = 3 edits: `inputs`, `outputs` destructure, `extraSpecialArgs` (if the module needs it)
- `llm-agents` input (github:numtide/llm-agents.nix) provides AI agent tooling; wire via its `overlays.shared-nixpkgs` overlay in flake.nix so packages live at `pkgs.llm-agents.<name>` and inherit our nixpkgs config. AI entries live in `private_modules/llm-agents.nix` (opencode2 = OpenCode v2 line — note `opencode` in that repo is the old v1, qwen-code, antigravity-cli, rtk, orca, since 2026-11-07) and are auto-updated by upstream daily — run `nix flake lock --update-input llm-agents` to pick up bumps. Upstream tests against a reasonably current unstable, while we follow the pinned 26.05 rev (see above): if an llm-agents build breaks, give *this input* its own unstable `nixpkgs` rather than unpinning the global one. Note: direct `nix build github:...#<pkg>` outside the overlay currently fails on a `kandev` eval bug in llm-agents (`packages` output forces every package); the overlay path stays lazy and works.
- `keyguard` is NOT the nixpkgs package: `keyguard-latest` in home.nix installs the official prebuilt Linux release (nixpkgs lags upstream; a source bump would need regenerating Gradle deps.json). Bumping it = update `version`, `tag` in the release URL, and `sha256` (`nix hash file --sri`) together. The launcher is wrapProgram-wrapped with `ld.library` path of `dbus.lib` since ~2026-11-18: the app extracts a native theme lib to `~/.cache/nucleus` at runtime and dlopens it; that lib needs `libdbus-1.so.3`, which autoPatchelf cannot inject for runtime-extracted files. Missing libdbus made the app crash seconds after launch, silently taking the hosted SSH agent (`$XDG_RUNTIME_DIR/keyguard-ssh-agent.sock`) with it — symptom is every ssh returning `Permission denied` while the app window seems fine. If libdbus vanishes again, keyguard crashes on start: check `journalctl --user -u <keyguard unit>` for `UnsatisfiedLinkError ... libdbus-1.so.3`.
- New modules: create `private_modules/<name>.nix`, add to `modules` list
- The `private_` prefix on directories is mandatory for chezmoi
- `nixpkgs.config` set in `flake.nix` is IGNORED by home-manager's internal nixpkgs re-import; put nixpkgs config (allowUnfree, problems.handlers…) in `home.nix` as the `nixpkgs.config` module option where it actually applies
- `problems.handlers.<pkg>.broken = "warn"` only permits EVALUATION of broken deps; it cannot un-break a genuinely failing build (e.g. azure-cli/fabric vs invoke ≥3, removed 2026-11-03 until upstream fixes)
- `buildEnv` collisions in `home.packages` ("two given paths contain a conflicting subpath") are resolved with `lib.lowPrio` on the losing package — the builder honours `meta.priority` and needs no rebuild (`pkgs.lowPrio` was removed in 26.05). Current case: 26.05's `wrangler` and `pi-coding-agent` both vendor `lib/node_modules/@types/node/index.d.ts`
- GNOME extension attrs come from the nixpkgs scrape of extensions.gnome.org filtered by the packaged shell versions (49/50/51): extensions lacking current shell support (e.g. `topiconsfix`, `campeek`) drop out of the set and break the build — replace with maintained successors (`tray-icons-reloaded`) or comment out with a dated note. Reject extensions doing blocking work in the shell process — `ddterm` (`spawn_sync`), `smart-home` and `ip-finder` (synchronous `Soup` HTTP) each froze the shell around lock/unlock; removed 2026-11-15. `gsconnect` is fine, it runs its service in a separate gjs process
- Usecase-driven debug: `nix eval --impure --expr 'builtins.getFlake "/home/papanito/.config/home-manager" …'` to probe attrs before editing
- OpenCode reaches ollama.com directly (`~/.config/opencode/opencode.json`, provider `ollama-cloud`, `settings.baseURL = https://ollama.com/v1`); the Bearer key lives in OpenCode's own credential store (`opencode.db`, table `credential`, id `ollama-cloud`), not in any chezmoi file. The safeagents proxy module that previously sat in between was deleted 2026-11-18 — do not re-add a proxy before OpenCode's baseURL without keeping them in sync, or OpenCode loses model access. `opencode.json` itself is opencode-owned runtime state, not chezmoi-managed.

## Verification

- `nix-instantiate --parse flake.nix` (syntax check, needs `LD_LIBRARY_PATH` unset on NixOS)
- `nix flake check` for full flake validation
- `home-manager switch --flake .#papanito` to apply (or just `ca` — full chezmoi apply triggers it via post script; the single-target `chezmoi apply ~/.config/home-manager/<file>` variants do too)
- `home-manager generations | head -3` to confirm a new generation is current

## Child DOX Index

No child AGENTS.md files — modules are flat files, not durable sub-boundaries.