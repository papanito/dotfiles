# DOX framework

## Core Contract

- DOX is the AGENTS.md hierarchy installed here; follow it across every edit.
- AGENTS.md files are binding work contracts for their subtrees.
- Work products, source materials, instructions, records, assets, and durable docs stay understandable from the nearest applicable AGENTS.md plus every parent AGENTS.md above it.

## Read Before Editing

1. Read the root AGENTS.md.
2. Identify every file or folder you expect to touch.
3. Walk from the repository root to each target path.
4. Read every AGENTS.md found along each route.
5. If a parent AGENTS.md lists a child AGENTS.md whose scope contains the path, read that child and continue from there.
6. Use the nearest AGENTS.md as the local contract; parent docs carry repo-wide rules.
7. If docs conflict, the closer doc controls local work details, but no child doc may weaken DOX.

Do not rely on memory. Re-read the applicable DOX chain in the current session before editing.

## Update After Editing

Every meaningful change requires a DOX pass before the task is done.

Update the closest owning AGENTS.md when a change affects:

- purpose, scope, ownership, or responsibilities
- durable structure, contracts, workflows, or operating rules
- required inputs, outputs, permissions, constraints, side effects, or artifacts
- AGENTS.md creation, deletion, move, rename, or index contents

Update parent docs when parent-level structure, ownership, workflow, or child index changes. Update child docs when parent changes alter local rules. Remove stale or contradictory text immediately. Small edits that do not change behavior or contracts may leave docs unchanged, but the DOX pass still must happen.

## Hierarchy

- Root AGENTS.md is the DOX rail: project-wide rules, global preferences, durable workflow rules, and the top-level Child DOX Index.
- Child AGENTS.md files own domain-specific instructions and their own Child DOX Index.
- Each parent explains what its direct children cover and what stays owned by the parent.
- The closer a doc is to the work, the more specific and practical it must be.

## Child Doc Shape

- Create a child AGENTS.md when a folder becomes a durable boundary with its own purpose, rules, responsibilities, workflow, materials, or quality standards.
- Section order: Purpose, Ownership, Local Contracts, Work Guidance, Verification, Child DOX Index.
- Work Guidance reflects current standards; leave it empty when there are none.
- Verification must be an existing check; leave it empty until one exists.

## Permissions

- Managed targets are user-only: files `0600`, directories `0700`. Never world-readable, world-writable, or world-executable.
- Group access only where a shared consumer requires it; nothing in this repo currently does.
- Declare modes per entry: `private_` for files and directories, `private_executable_` for executables. Attributes do not cascade — every file inside a private directory needs its own `private_`.
- Plain entries follow the run-time umask; never rely on umask, an apply with `022` restores `0644`/`0755`.
- `.chezmoiexternal.toml` keys take no attributes. Their roots and the parent dirs chezmoi creates for them stay at umask modes; leave those modes alone, an apply resets the tracked parents.

## Style

- Docs and comments stay terse: state the rule, not the reason.
- No rationale, history, or "why" in AGENTS.md or code comments; rationale belongs in the commit message.
- Document stable contracts, not diary entries.
- Broad rules in parent docs, concrete details in child docs.
- Prefer direct bullets with explicit names.
- Do not duplicate rules across files unless each scope needs a local version.
- Delete stale notes instead of explaining history.
- Trim obvious statements, repeated rules, misplaced detail, and warnings for risks that no longer exist.

## Closeout

1. Re-check changed paths against the DOX chain.
2. Update the nearest owning docs and any affected parents or children.
3. Refresh every affected Child DOX Index.
4. Remove stale or contradictory text.
5. Run existing verification when relevant.
6. Report docs intentionally left unchanged and why.
7. Commit the changes before finishing: every instruction or task ends with a commit that includes all repo changes it produced, with the rationale in the commit message.

## User Preferences

- `nix develop` opens zsh, not bash: a `nix()` wrapper in `private_dot_zshrc.tmpl` appends `-c zsh` to bare `nix develop` calls; explicit `-c`/`--command` calls pass through.
- `~/.config/opencode/AGENTS.md` is acman-managed (the `agents-md` catalog rule appends the CodeGraph block), not chezmoi. Never add it to chezmoi source.
- Agent skills are always acman-managed, never chezmoi: no `skills/` trees (OpenCode, Claude Code, Antigravity, …) or their `agents/`/`commands/` siblings in chezmoi source.
- Comments and docs state rules only. Rationale, history, and "why" go in the commit message.
- Every instruction ends with a commit of all resulting repo changes; work is not done while changes stay uncommitted.

## Child DOX Index

- `private_dot_config/private_home-manager/` — Standalone Home Manager flake: flake inputs, service modules, and the `home.nix` package list. See its AGENTS.md; `private_pkgs/` has its own for vendored packages.
- `private_dot_omp/private_agent/` — oh-my-pi (omp) model catalog and routing/failover config. Chezmoi source is authoritative; `~/.omp/agent/` is omp-managed. No in-repo AGENTS.md.
- `private_dot_config/private_orca/` — Portable Orca ADE settings snapshot and the `orca-settings` export/import contract. See its AGENTS.md.
- `private_dot_config/private_opencode/` — OpenCode v2 user config: `cli.json` and `opencode.json`. No in-repo AGENTS.md; the target `~/.config/opencode/AGENTS.md` is acman-managed.
