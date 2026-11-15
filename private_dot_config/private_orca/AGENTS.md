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
- Import is a **top-level** merge (`merged.update(snapshot)`), while export strips every `claude`/`codex` key and every agent value inside lists. Importing the full snapshot therefore replaces `disabledTuiAgents` and `agentDefaultArgs` wholesale — re-enabling the claude and codex TUI agents and dropping their default args. To change one setting, import a partial snapshot such as `{"openInApplications": [...]}`; the dry run must report that one key only.
- The snapshot is generated, not hand-edited. After changing settings in Orca: `~/.config/orca/orca-settings export`, then `chezmoi add ~/.config/orca/settings.portable.json`.

## Work Guidance

- Change the portable set via `DROP_TOP_LEVEL` / `DROP_KEY_PATTERN` / `DROP_BOOKKEEPING_PATTERN` in the helper, then re-export so script and snapshot stay in sync; commit both together.
- Preview with `~/.config/orca/orca-settings import --dry-run`; it lists added/changed keys and writes nothing.
- Orca rewrites its database continuously while running, so export may pick up fresh state; import must always run with Orca closed.
- New host: install Orca, launch it once so the profile database exists, quit it, then run `~/.config/orca/orca-settings import`.
- `--profile <id>` selects a non-active profile; `--snapshot <path>` targets another snapshot (used for testing).
- `openInApplications` only fills each workspace's **Open in** menu; there is no "default editor" setting, and the fallback for actions that name no app is the hard-coded `BUILT_IN_EDITOR_COMMANDS.vscode` = `code`. Orca spawns these commands detached with `stdio: 'ignore'` (no PTY), so a TUI editor needs a terminal wrapper — `kgx -- nvim` is the working form here (GNOME Console is the only emulator installed), while bare `nvim` exits immediately.

## Verification

- `python3 -c 'compile(open("private_dot_config/private_orca/executable_orca-settings").read(), "orca-settings", "exec")'`
- `python3 -c 'import json; json.load(open("private_dot_config/private_orca/settings.portable.json"))'`
- `~/.config/orca/orca-settings import --dry-run` on a configured host prints `settings already match the snapshot; nothing to do`.

## Child DOX Index

No child AGENTS.md files — this is a single snapshot plus its helper contract.
