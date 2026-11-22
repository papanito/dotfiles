# Home Manager Flake

## Purpose

Standalone Home Manager configuration for user `papanito`, managed as a Nix flake with custom service modules.

## Ownership

- Edited only in chezmoi source: `private_dot_config/private_home-manager/`
- Applied via `home-manager switch --flake .#papanito`
- Runtime target: `~/.config/home-manager/` (chezmoi-managed)

## Local Contracts

- Flake inputs are declared in `flake.nix`, destructured in `outputs`, and passed to modules via `extraSpecialArgs`.
- `nixpkgs` is pinned to the exact rev in `/etc/nixos/flake.lock` (nixos-26.05 `c56a87d`); `home-manager` tracks `release-26.05`. Bump both here and in `/etc/nixos` together; never unpin the global nixpkgs for a single input.
- SSH agent is Keyguard's built-in agent, socket `$XDG_RUNTIME_DIR/keyguard-ssh-agent.sock`, exported as `SSH_AUTH_SOCK` through `systemd.user.sessionVariables`. The path is literal. Bitwarden desktop stays out of the session: chezmoi stub `~/.config/autostart/bitwarden.desktop` (`Hidden=true`), in-app login and SSH-agent toggles off, and the shell startup files export the same socket.
- User-facing desktop apps (guake, flameshot, keyguard, GNOME extensions) are installed in `home.packages`, not in the host's `hosts/<host>/packages.nix`. guake spans `home.nix`, `modules/gnome.nix`, and `~/.config/autostart/guake.desktop`.
- Each service is a self-contained module in `private_modules/` (chezmoi `private_` prefix), added to the `modules` list in `flake.nix` `homeConfigurations."papanito"`.
- Systemd user services follow the pattern in `llama-cpp.nix` / `watchman.nix` (Unit/Service/Install).
- Watchman tuning lives in `/etc/watchman.json` (nixos-configuration `profiles/pc`) and per-root `.watchmanconfig`. Do not add `~/.watchman.json` or `~/.watchmanconfig`.

## Work Guidance

- Adding a flake input = 3 edits: `inputs`, `outputs` destructure, `extraSpecialArgs` (if the module needs it).
- `llm-agents` (github:numtide/llm-agents.nix) is wired through its `overlays.shared-nixpkgs` overlay, so packages live at `pkgs.llm-agents.<name>`. AI entries live in `private_modules/llm-agents.nix`; bump with `nix flake lock --update-input llm-agents`. If an llm-agents build breaks, give that input its own unstable `nixpkgs` instead of unpinning the global one.
- `keyguard-latest` (vendored in `private_pkgs/keyguard.nix`) is not the nixpkgs package; bump `version`, release `tag`, and `sha256` together.
- New modules: create `private_modules/<name>.nix`, add to the `modules` list.
- The `private_` prefix on directories is mandatory for chezmoi.
- `nixpkgs.config` in `flake.nix` is ignored by home-manager's internal nixpkgs re-import; set it in `home.nix` as the `nixpkgs.config` module option.
- `problems.handlers.<pkg>.broken = "warn"` only permits evaluation; it cannot fix a failing build.
- `buildEnv` collisions in `home.packages` are resolved with `lib.lowPrio` on the losing package.
- GNOME extension attrs come from the nixpkgs scrape filtered by the packaged shell versions (49/50/51). Keep only extensions with current shell support and no blocking work in the shell process. Hue control is `openhue-cli` + `hue-menu` (rofi) in `hue.nix`; no in-shell Hue extension.
- Debug attrs with `nix eval --impure --expr 'builtins.getFlake "/home/papanito/.config/home-manager" …'`.
- `private_modules/nix-gc.nix` runs the weekly `nix-user-gc` timer: keep the newest four `~/.local/state/nix/profiles/profile` generations, then `nix-collect-garbage`. Manual run: `systemctl --user start nix-user-gc.service`.
- Vendored packages live in `private_pkgs/`; see its AGENTS.md.
- OpenCode reaches ollama.com directly (`settings.baseURL = https://ollama.com/v1`) and keeps the Bearer key in its own credential store (`opencode.db`, table `credential`, id `ollama-cloud`). Do not put a proxy in front of that baseURL. Chezmoi owns only `~/.config/opencode/cli.json` and `opencode.json`; the rules doc there is acman-managed.

## Verification

- `nix-instantiate --parse flake.nix` (with `LD_LIBRARY_PATH` unset)
- `nix flake check`
- `home-manager switch --flake .#papanito` (or `ca`; chezmoi apply runs it through the post hook)
- `home-manager generations | head -3`

## Child DOX Index

- `private_pkgs/` — one `{ pkgs, lib }: <package>` function per file for packages absent from nixpkgs (`keyguard.nix`, `rwx.nix`), imported by `home.nix`. See its AGENTS.md. Other modules are flat files, not durable sub-boundaries.
