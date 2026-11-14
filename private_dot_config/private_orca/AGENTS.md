# Orca settings

## Purpose

Portable snapshot of Orca ADE (`orca-ide`) app settings, so the configuration made in Orca's Settings pane can be reproduced on another host.

## Ownership

- `settings.portable.json` in this directory — chezmoi source of truth for the portable settings.
- `~/.config/orca/profiles/<profile>/profile-state.db` — live state owned by Orca. Settings are the `settings` document in `profile_state_documents`; there is no settings file.
- `~/.config/orca/orca-settings` — export/import helper; source is `private_orca/executable_orca-settings`.

## Local Contracts

- The snapshot is the full effective settings minus `claude`/`codex` keys, migration/default bookkeeping, machine-local values (`workspaceDir`, `telemetry.installId`, proxy config, Windows/WSL/Android host paths) and secrets (`opencodeSessionCookie`).
- `chezmoi apply` never writes to `profile-state.db`. Applying is an explicit `~/.config/orca/orca-settings import` with Orca stopped; the helper backs up `profile-state.db*` to `~/.config/orca/chezmoi-backups/<timestamp>/` and bumps the document revision.
- Import merges into the host profile: keys absent from the snapshot (agent accounts, per-host model caches, projects) are left untouched.
- The snapshot is generated, not hand-edited. After changing settings in Orca: `~/.config/orca/orca-settings export`, then `chezmoi add ~/.config/orca/settings.portable.json`.

## Work Guidance

- Change the portable set via `DROP_TOP_LEVEL` / `DROP_KEY_PATTERN` / `DROP_BOOKKEEPING_PATTERN` in the helper, then re-export so script and snapshot stay in sync; commit both together.
- Preview with `~/.config/orca/orca-settings import --dry-run`; it lists added/changed keys and writes nothing.
- Orca rewrites its database continuously while running, so export may pick up fresh state; import must always run with Orca closed.
- New host: install Orca, launch it once so the profile database exists, quit it, then run `~/.config/orca/orca-settings import`.
- `--profile <id>` selects a non-active profile; `--snapshot <path>` targets another snapshot (used for testing).

## Verification

- `python3 -c 'compile(open("private_dot_config/private_orca/executable_orca-settings").read(), "orca-settings", "exec")'`
- `python3 -c 'import json; json.load(open("private_dot_config/private_orca/settings.portable.json"))'`
- `~/.config/orca/orca-settings import --dry-run` on a configured host prints `settings already match the snapshot; nothing to do`.

## Child DOX Index

No child AGENTS.md files — this is a single snapshot plus its helper contract.
