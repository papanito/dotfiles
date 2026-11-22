# Orca settings

## Purpose

Portable snapshot of Orca ADE (`orca-ide`) app settings, so the configuration made in Orca's Settings pane can be reproduced on another host.

## Ownership

- `settings.portable.json` in this directory — chezmoi source of truth for the portable settings.
- `~/.config/orca/profiles/<profile>/profile-state.db` — live state owned by Orca. Settings are the `settings` document in `profile_state_documents`; there is no settings file.
- `~/.config/orca/orca-settings` — export/import helper; source is `private_orca/executable_orca-settings`.
- `~/.config/autostart/orca.desktop` — login autostart, chezmoi-owned (`private_dot_config/autostart/orca.desktop`); it execs `~/.nix-profile/bin/orca-ide` because the profile path survives version bumps, unlike the `/nix/store` target and the `~/.local/bin/orca-ide` symlink Orca recreates.

## Local Contracts

- The snapshot is the full effective settings minus `claude`/`codex` keys, migration/default bookkeeping, machine-local values (`workspaceDir`, `telemetry.installId`, proxy config, Windows/WSL/Android host paths) and secrets (`opencodeSessionCookie`).
- `chezmoi apply` never writes to `profile-state.db`. Applying is an explicit `~/.config/orca/orca-settings import` with Orca stopped; the helper backs up `profile-state.db*` to `~/.config/orca/chezmoi-backups/<timestamp>/` and bumps the document revision.
- Import merges into the host profile: keys absent from the snapshot (agent accounts, per-host model caches, projects) are left untouched.
- Import is a **top-level** merge (`merged.update(snapshot)`), while export strips every `claude`/`codex` key and every agent value inside lists. Importing the full snapshot therefore replaces `disabledTuiAgents` and `agentDefaultArgs` wholesale — re-enabling the claude and codex TUI agents and dropping their default args. To change one setting, import a partial snapshot such as `{"openInApplications": [...]}`; the dry run must report that one key only.
- The snapshot is generated, not hand-edited. After changing settings in Orca: `~/.config/orca/orca-settings export`, then `chezmoi add ~/.config/orca/settings.portable.json`.

## Work Guidance

- Change the portable set via `DROP_TOP_LEVEL` / `DROP_KEY_PATTERN` / `DROP_BOOKKEEPING_PATTERN` in the helper, then re-export so script and snapshot stay in sync; commit both together.
- Preview with `~/.config/orca/orca-settings import --dry-run`; it lists added/changed keys and writes nothing.
- Orca rewrites its database continuously while running, so export may pick up fresh state; import must always run with Orca closed.
- New host: install Orca, launch it once so the profile database exists, quit it, then run `~/.config/orca/orca-settings import`.
- `--profile <id>` selects a non-active profile; `--snapshot <path>` targets another snapshot (used for testing).
- `openInApplications` only fills each workspace's **Open in** menu; there is no "default editor" setting, and the fallback for actions that name no app is the hard-coded `BUILT_IN_EDITOR_COMMANDS.vscode` = `code`. Orca spawns these commands detached with `stdio: 'ignore'` (no PTY), so a TUI editor needs a terminal wrapper — the working form here is `kgx -- /home/papanito/.nix-profile/bin/nvim` (GNOME Console is the only emulator installed). Use an absolute binary path: the spawn env is sanitized, so `~/.nix-profile/bin` is not on `PATH`, and bare `nvim` both misses and dies without a TTY.

## Model list

- There is no Orca setting to hide models/providers. The picker is the union of each agent's own catalog: opencode → the provider registry in `~/.config/opencode/opencode.json` (chezmoi-managed via `private_dot_config/private_opencode/`), omp → `~/.omp`, pi → `~/.config/pi`. Orca caches the result in `~/.config/orca/agent-model-catalog.json`.
- Hide a whole provider at the opencode source with `"disabled_providers": ["<id>"]` (or `enabled_providers` as an allow-list) in `~/.config/opencode/opencode.json`, then `opencode2 reload`; already-running Orca agent sessions keep their cached list, so reopen the chat/restart Orca to re-discover. Both keys are marked deprecated in the v2 schema but still honored in opencode 2.2.6 (verified: the CLI list drops to the allowed providers).
- Providers auto-load when opencode finds credentials in the environment. `CLOUDFLARE_ACCOUNT_ID` (from `~/.zshenv.tmpl`) alone makes the unusable `cloudflare-ai-gateway` provider appear, which is why it is disabled explicitly here.

## Verification

- `python3 -c 'compile(open("private_dot_config/private_orca/executable_orca-settings").read(), "orca-settings", "exec")'`
- `python3 -c 'import json; json.load(open("private_dot_config/private_orca/settings.portable.json"))'`
- `~/.config/orca/orca-settings import --dry-run` on a configured host prints `settings already match the snapshot; nothing to do`.
- `opencode2 models | grep -c '^cloudflare-ai-gateway/'` prints `0` while the provider is disabled.

## Child DOX Index

No child AGENTS.md files — this is a single snapshot plus its helper contract.
