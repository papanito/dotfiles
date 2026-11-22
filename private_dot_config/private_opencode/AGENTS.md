# OpenCode config

## Purpose

Chezmoi source for the user-level OpenCode v2 configuration in `~/.config/opencode/`, so keybinds and the provider registry survive reinstall and are shared across hosts.

## Ownership

- `cli.json` → `~/.config/opencode/cli.json`: CLI/TUI preferences (keybinds, theme).
- `private_executable_opencode.json` → `~/.config/opencode/opencode.json`: OpenCode v2 provider registry, default model, provider visibility. Source attributes keep the target private and executable because OpenCode creates it as `0700`.
- `~/.local/share/opencode/opencode.db`, table `credential`: OpenCode's own credential store (e.g. id `ollama-cloud`). Never copied into chezmoi.
- `~/.config/home-manager/private_modules/opencode.nix`: the `opencode-server` systemd unit that runs `opencode2 serve` on port 4096.

## Local Contracts

- Secrets stay in the credential store or in environment variables; `opencode.json` only references them through OpenCode's own `${VAR}` interpolation (`openrouter`, `google`). These are not chezmoi templates — do not convert them.
- `providers.ollama-cloud.settings.baseURL = https://ollama.com/v1` talks to ollama.com directly. Do not put a proxy in front of it unless the proxy is in sync (the safeagents proxy was removed 2026-11-18); otherwise model access breaks.
- `disabled_providers` / `enabled_providers` filter the provider registry; OpenCode 2.2.6 still honors both although the v2 schema marks them deprecated. This is the only lever for Orca's model picker: Orca has no model-visibility setting and builds its list from this registry. `cloudflare-ai-gateway` is disabled here because `CLOUDFLARE_ACCOUNT_ID` from `~/.zshenv.tmpl` makes OpenCode auto-load it without a usable gateway.
- OpenCode owns `opencode.json` at runtime and may rewrite it (wizard, in-app settings). After such a change, re-add it with `chezmoi add ~/.config/opencode/opencode.json` so the source stays authoritative; `chezmoi apply` overwrites local edits.

## Work Guidance

- Change providers/models by editing the source file, then `chezmoi apply ~/.config/opencode/opencode.json` and `opencode2 reload`.
- Hiding a provider: add its id to `disabled_providers`, or use `enabled_providers` as an allow-list. Running Orca agent sessions keep their cached catalog, so open a new chat or restart Orca.
- Keep `$schema` on `https://opencode.ai/config.json`; validate with `opencode2 debug config` if available or plain JSON parsing.

## Verification

- `python3 -c 'import json; json.load(open("private_dot_config/private_opencode/private_executable_opencode.json"))'`
- `chezmoi diff ~/.config/opencode/opencode.json` prints nothing.
- `opencode2 models | grep -c '^cloudflare-ai-gateway/'` prints `0` while that provider is disabled.

## Child DOX Index

No child AGENTS.md files — this directory holds two config files plus their contracts.
