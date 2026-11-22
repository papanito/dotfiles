# Orca settings

## Purpose

Portable snapshot of Orca ADE (`orca-ide`) app settings, so the Settings pane configuration can be reproduced on another host.

## Ownership

- `settings.portable.json` — chezmoi source of truth for the portable settings.
- `~/.config/orca/profiles/<profile>/profile-state.db` — live state, owned by Orca. Settings are the `settings` document in `profile_state_documents`; there is no settings file.
- `~/.config/orca/orca-settings` — export/import helper; source is `private_executable_orca-settings` in this directory.
- `~/.config/autostart/orca.desktop` — login autostart, chezmoi-owned (`private_dot_config/private_autostart/private_orca.desktop`). It execs `~/.nix-profile/bin/orca-ide`.

## Local Contracts

- The snapshot is the full effective settings minus `claude`/`codex` keys, migration/default bookkeeping, machine-local values (`workspaceDir`, `telemetry.installId`, proxy config, Windows/WSL/Android host paths), and secrets (`opencodeSessionCookie`).
- `chezmoi apply` never writes `profile-state.db`. Applying is an explicit `~/.config/orca/orca-settings import` with Orca stopped; the helper backs up `profile-state.db*` to `~/.config/orca/chezmoi-backups/<timestamp>/` and bumps the document revision.
- Import merges into the host profile: keys absent from the snapshot (agent accounts, per-host model caches, projects) stay untouched.
- Import is a **top-level** merge (`merged.update(snapshot)`), while export strips every `claude`/`codex` key and every agent value inside lists. Importing the full snapshot replaces `disabledTuiAgents` and `agentDefaultArgs` wholesale. To change one setting, import a partial snapshot such as `{"openInApplications": [...]}`; the dry run must report only those keys.
- The snapshot is generated, not hand-edited. After changing settings in Orca: `~/.config/orca/orca-settings export`, then `chezmoi add ~/.config/orca/settings.portable.json`.

## Work Guidance

- Change the portable set via `DROP_TOP_LEVEL` / `DROP_KEY_PATTERN` / `DROP_BOOKKEEPING_PATTERN` in the helper, then re-export so script and snapshot stay in sync; commit both together.
- Preview with `~/.config/orca/orca-settings import --dry-run`; it lists added/changed keys and writes nothing.
- Orca rewrites its database while running: export may pick up fresh state, import requires Orca closed.
- New host: install Orca, launch it once so the profile database exists, quit it, then run `~/.config/orca/orca-settings import`.
- `--profile <id>` selects a non-active profile; `--snapshot <path>` targets another snapshot.
- `openInApplications` only fills each workspace's **Open in** menu. The fallback is the hard-coded `BUILT_IN_EDITOR_COMMANDS.vscode` = `code`. Orca spawns these commands detached without a PTY, so a TUI editor needs a terminal wrapper; the working form is `kgx -- /home/papanito/.nix-profile/bin/nvim`. Use absolute paths: the spawn env is sanitized and `~/.nix-profile/bin` is not on `PATH`.

## Model list

- No setting hides models or providers. The picker is the union of each agent's catalog: opencode → the provider registry in `~/.config/opencode/opencode.json` (chezmoi-managed), omp → `~/.omp`, pi → `~/.config/pi`. Orca caches the result in `~/.config/orca/agent-model-catalog.json`.
- Hide a provider at the opencode source with `"disabled_providers": ["<id>"]` (or `enabled_providers` as an allow-list) in `~/.config/opencode/opencode.json`, then `opencode2 reload`; running Orca agent sessions keep their cached list, so reopen the chat.
- Providers auto-load when opencode finds credentials in the environment. `CLOUDFLARE_ACCOUNT_ID` alone makes the unusable `cloudflare-ai-gateway` provider appear, so it is disabled explicitly.

## Verification

- `python3 -c 'compile(open("private_dot_config/private_orca/private_executable_orca-settings").read(), "orca-settings", "exec")'`
- `python3 -c 'import json; json.load(open("private_dot_config/private_orca/settings.portable.json"))'`
- `~/.config/orca/orca-settings import --dry-run` on a configured host prints `settings already match the snapshot; nothing to do`.
- `opencode2 models | grep -c '^cloudflare-ai-gateway/'` prints `0` while that provider is disabled.

## Child DOX Index

No child AGENTS.md files — a single snapshot plus its helper contract.
