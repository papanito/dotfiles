# 🚀 papanito's Dotfiles

Personal configuration for a declarative and reproducible development environment. Built with **[Nix]**, managed via **[home-manager]** (optional), and deployed using **[chezmoi]**.

## 📦 Quick Start & Installation

This setup assumes you have [chezmoi](https://www.chezmoi.io/install/) installed.

Optionally should also install [home-manager].

> [!REMARK]
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

I use direnv to load environment variables using [bitwarden] or [bws]. [this file](./private_dot_config/direnv/lib/executable_bw_to_env.sh) contains 2 Functions

* `bw_env` - use [bitwarden] which will require to login/unlock the vault
* `bws_env` - use [bws] which only contains the environment variables and not all personal passwords (hence my preferred solution)

So I can use the following in `.envrc` files to automatically inject secrets automatically

```shell
bws_env -p personal RESTIC_PASSWORD
bws_env -p private B2_ACCOUNT_KEY B2_ACCOUNT_ID
```

## ❄️NixOS Home Manager

Where I have [Nix] installed, I manage some desktop settings with [home-manager]:

* [View NixOS Configs](./private_dot_config/home-manager/§)
* [View home.nix](./private_dot_config/home-manager/home.nix)

### ⚙️Systemd User Services

I manage background processes via **systemd user services**, which run in the user context (`systemctl --user`). This allows for automated management of daemons without requiring root privileges.

* **[paperless-sync](./private_dot_config/home-manager/modules/paperless-sync.nix)**: Regurarily pulls documents from [paperless-server][paperless-nxg]
* **[watchman](./private_dot_config/home-manager/modules/watchman.nix)**: Starts [watchman] socket
* **[pueue](./private_dot_config/home-manager/modules/pueue.nix.nix)**: Starts [pueue] daemon

[zellij]: https://zellij.dev/
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
[home.nix]: ./private-dot_config/home-manager/home.nix
[Aliases & Functions]: ./private_dot_config/dotfiles/
[zsh]: https://www.zsh.org/
[pueue]: https://github.com/Nukesor/pueue
