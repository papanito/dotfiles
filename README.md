# 🚀 papanito's Dotfiles

Personal configuration for a declarative and reproducible development environment. Built with **[Nix]**, managed via **[home-manager]** (optional), and deployed using **[chezmoi]**.

## 📦 Quick Start & Installation

This setup assumes you have [chezmoi](https://www.chezmoi.io/install/) installed.

Optionally should also install [home-manager].

> [!important] Remark
>
> Instead of using [home-manager] to manage all my dotfiles, I use [chezmoi] as my primary tool.
> I use **home-manager** to declaratively manage user-specific packages and environment logic.
> This is an optional part of the setup; the core dotfiles can function independently, especially as I still have machines without nix.

### Initialize chezmoi

This clones the repo into ~/.local/share/chezmoi

```bash
chezmoi init https://github.com/papanito/dotfiles.git
```

### Configure [home-manager]

Home Manager is a Nix-based tool that allows you to manage your user-specific configuration and packages declaratively, similar to how NixOS manages an entire system.

I configure [chezmoi] to run `home-manager switch` whenever I run `chezmoi apply`

```ini
[hooks.apply.post]
command = "home-manager"
args = [
    "switch",
    "--flake",
    "/home/papanito/.config/home-manager"
]
```

## 🛠 Tech Stack

My environment uses the following basic tools:

* **Shell:** [zsh] as my primary shell using
  * **[zinit]** to manage plugins for sub-second startup times using Turbo (asynchronous) loading.
  * **[atuin]** an SQLite-powered shell history
  * **[direnv](https://direnv.net/)** to automatically load environment variables and Nix shells when entering a directory.
  * **[oh-my-posh]** as my prompt for a consistent, informative, and aesthetic prompt across any shell.
  * **[Aliases & Functions]** to work faster on the shell
* **Editor:** [Neovim] configured with the **[LazyVim]** distro for a modular, high-performance IDE experience.
* **Workspace:** **[Zellij][zellij]** — A modern terminal workspace and multiplexer with built-in layouts.
* **Workspace (TUI OS):** **[Tuios][tuios]** — A terminal-based window manager; a background daemon keeps its sessions alive across detaches.

### 🤖 AI Tooling

|Tool|Description|
|----|-----------|
|[OpenCode][opencode]|Terminal AI coding agent (OpenCode 2 CLI) with pluggable model providers and MCP servers.|
|[Orca][orca]|Orca ADE — desktop app (`orca-ide`) plus an `orca` CLI for running coding agents in parallel worktrees.|
|[acman][acman]|Git-backed agent configuration manager: one catalog repo, content picked by tag or profile and symlinked into each agent's config directory.|

### 🔧 Core Tools & CLI Utilities

Here are some tools worth mentioning - check [home.nix] for more tools

|Tool|Description|
|----|-----------|
|[bitwarden]|Password manager to manage not only password but also use it as [ssh-key agent](https://wyssmann.com/blog/2026/01/user-bitwarden-as-ssh-agent/)|
|[bws]|Bitwarden secret manager in combination with direnv to inject environment variables.|
|[zoxide]|A smarter cd command that learns your habits.|
|[fzf]|General-purpose command-line fuzzy finder.|
|[ripgrep] (rg)|Blazing fast recursive line-oriented search.|
|[bat]|A cat clone with syntax highlighting and git integration.|
|[eza]|A modern, maintained replacement for ls.|
|[watchman]|Watches files and records, or triggers actions, when they change.|
|[pueue]|Pueue is a command-line task management tool for sequential and parallel execution of long-running tasks.|

### 📂 Direnv & Environment Management

I use direnv to load environment variables using [bitwarden] or [bws]. [this file](./private_dot_config/private_direnv/private_lib/executable_bw_to_env.sh) contains 2 Functions

* `bw_env` - use [bitwarden] which will require to login/unlock the vault
* `bws_env` - use [bws] which only contains the environment variables and not all personal passwords (hence my preferred solution)

So I can use the following in `.envrc` files to automatically inject secrets automatically

```shell
bws_env -p personal RESTIC_PASSWORD
bws_env -p private B2_ACCOUNT_KEY B2_ACCOUNT_ID
```

## ☁️ Cloud & Networking

What lives outside the LAN is declarative too: hosts join the tailnet by themselves, the homelab is published without opening inbound ports, and provider-side state (zones, DNS) is managed as code instead of dashboard clicks.

|What|How|
|----|-----------|
|[Tailscale][tailscale]|Every host joins the tailnet as a client node (`useRoutingFeatures = "client"`), with one reusable auth key delivered from sops — no host becomes a subnet router. [config][tailscale-nix]|
|[Cloudflare Tunnel][cf-tunnel]|`cloudflared` exposes homelab services without inbound ports; origin certs live in `~/.cloudflared`, the host setup in [cloudflare.nix][cf-nix], and WARP is available for device-level access.|
|[Cloudflare Workers][cf-workers]|Edge functions and static assets deployed with [wrangler] — `wrangler.jsonc` + `wrangler.production.jsonc` per project (e.g. eventcompass).|
|[Backblaze B2][b2] + [restic]|`services.restic.backups.b2` pushes encrypted, deduplicated snapshots to `b2:<bucket>/<host>` daily; repo password and B2 keys come from sops, and a Google Chat notifier reports success and failure. [config][restic-nix]|
|[GitLab][gitlab]|Primary CI/CD and secrets backend: the flake-update + [Colmena][colmena] deployment pipeline runs on a project-scoped shell runner, and deploy secrets are protected CI/CD variables (`CI_PUSH_TOKEN`, `NIXOS_SSH_KEY_FILE`). [pipeline][gl-ci]|
|[Terraform][terraform]|Manages the provider side as code — Cloudflare account and zone IDs in `variables.tfvars` — so zones and DNS are reviewed, not clicked. [config][tf-nix]|

The infrastructure itself lives in the [nixos-configuration][nixos-configuration] repo; the local tooling (`cloudflared`, `wrangler`, `cloudflare-cli`, `cloudflare-utils`, `terraform`, `restic`, `autorestic`) comes from [home.nix].

## ❄️NixOS Home Manager

Where I have [Nix] installed, I manage some desktop settings with [home-manager]:

* [View the home-manager flake](./private_dot_config/private_home-manager/)
* [View home.nix](./private_dot_config/private_home-manager/home.nix)
* [View the NixOS system configuration][nixos-configuration] (hosts, profiles, server services such as [paperless-ngx][paperless-server-config])

### ⚙️Systemd User Services

I manage background processes via **systemd user services**, which run in the user context (`systemctl --user`). This allows for automated management of daemons without requiring root privileges.

* **[paperless-sync](./private_dot_config/private_home-manager/private_modules/paperless-sync.nix)**: Regularly pulls documents from [paperless-ngx][paperless-ngx]; the server itself is defined in [nixos-configuration][paperless-server-config] (`hosts/lenovo/paperless-ngx.nix`)
* **[watchman](./private_dot_config/private_home-manager/private_modules/watchman.nix)**: Starts [watchman] socket
* **[pueue](./private_dot_config/private_home-manager/private_modules/pueue.nix)**: Starts [pueue] daemon

[zellij]: https://zellij.dev/
[tuios]: https://github.com/Gaurav-Gosain/tuios
[opencode]: https://opencode.ai/
[orca]: https://orca.dev/
[acman]: https://gitlab.com/wyssmann/acman
[LazyVim]: https://www.lazyvim.org/
[Neovim]: https://neovim.io/
[home-manager]: https://nix-community.github.io/home-manager/
[Nix]: https://nixos.org
[bitwarden]: https://bitwarden.com/
[bws]: https://bitwarden.com/products/secrets-manager/
[watchman]: https://facebook.github.io/watchman/
[chezmoi]: https://github.com/twpayne/chezmoi/
[oh-my-posh]: https://github.com/JanDeDobbeleer/oh-my-posh
[zinit]: https://github.com/zdharma-continuum/zinit
[atuin]: https://atuin.sh/
[zoxide]: https://github.com/ajeetdsouza/zoxide
[fzf]: https://github.com/junegunn/fzf
[ripgrep]: https://github.com/BurntSushi/ripgrep
[eza]: https://eza.rocks/
[bat]: https://github.com/sharkdp/bat
[home.nix]: ./private_dot_config/private_home-manager/home.nix
[Aliases & Functions]: ./private_dot_config/private_dotfiles/
[nixos-configuration]: https://gitlab.com/papanito/nixos-configuration
[paperless-server-config]: https://gitlab.com/papanito/nixos-configuration/-/blob/main/hosts/lenovo/paperless-ngx.nix
[paperless-ngx]: https://github.com/paperless-ngx/paperless-ngx
[tailscale]: https://tailscale.com/
[tailscale-nix]: https://gitlab.com/papanito/nixos-configuration/-/blob/main/common/tailscale.nix
[cf-tunnel]: https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/
[cf-nix]: https://gitlab.com/papanito/nixos-configuration/-/blob/main/hosts/clawfinger/networking/cloudflare.nix
[cf-workers]: https://www.cloudflare.com/products/workers/
[wrangler]: https://developers.cloudflare.com/workers/wrangler/
[b2]: https://www.backblaze.com/cloud-storage
[restic]: https://restic.net/
[restic-nix]: https://gitlab.com/papanito/nixos-configuration/-/blob/main/profiles/servers/restic.nix
[gitlab]: https://gitlab.com/
[colmena]: https://github.com/nix-community/colmena
[gl-ci]: https://gitlab.com/papanito/nixos-configuration/-/blob/main/.gitlab-ci.yml
[terraform]: https://developer.hashicorp.com/terraform
[tf-nix]: https://gitlab.com/papanito/nixos-configuration/-/blob/main/hosts/terraform/terraform/variables.tfvars
[zsh]: https://www.zsh.org/
[pueue]: https://github.com/Nukesor/pueue
