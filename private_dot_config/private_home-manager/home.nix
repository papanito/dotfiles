{
  pkgs,
  lib,
  config,
  home_attrs,
  security,
  inputs,
  ...
}:
let
  my-python-packages =
    ps: with ps; [
      pandas
      requests
      pip # The PyPA recommended tool for installing Python packages
      django
      pillow # The friendly PIL fork (Python Imaging Library)
      jupyter # A high-level dynamically-typed programming language
      notebook # Web-based notebook environment for interactive computing
    ];
  my-nodes-packages =
    ns: with ns; [
      prettier-plugin-toml
    ];
in
{
  home = {
    username = "papanito";
    homeDirectory = "/home/papanito";
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    #ssh.startAgent = true;
    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };

  # Check the Home Manager manual for the recommended version for your Nixpkgs.
  home.stateVersion = "26.05"; # Example, align with your nixpkgs release

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  home.packages = with pkgs; [
    # flakes
    inputs.pi-nix.packages."x86_64-linux".default
    inputs.omp-nix.packages."x86_64-linux".default
    inputs.herdr.packages."x86_64-linux".default
    #inputs.gwl.packages."x86_64-linux".default
    (pkgs.python3.withPackages my-python-packages)

    mise # package management for go an rustup
    pkg-config
    openssl

    ## nix tools
    nix-direnv # A fast, persistent use_nix implementation for direnv
    nixd # Nix LSP
    pyright # Python LSP
    terraform-ls # Terraform LSP
    colmena
    statix
    dconf2nix
    libsecret

    ## AI
    antigravity # Agentic development platform, evolving the IDE into the agent-first era
    ollama
    (lib.lowPrio llama-cpp) # C/C++ inference engine for LLaMA and other LLMs (CPU-only). lowPrio: handy also ships libggml-base.so.0

    ## Security
    keyguard # Bitwarden alternative
    opensnitch-ui
    gitleaks # Scan git repos (or files) for secrets
    rbw # Alternative bitwarden cli
    shellcheck # Shell script analysis tool
    snyk # snyk library and cli utility
    tirith # URL security analysis for shell environments
    trivy

    ## Database
    dbeaver-bin # Universal SQL Client for developers, DBA and analysts. Supports MySQL, PostgreSQL, MariaDB, SQLite, and more
    dbgate # Database manager for MySQL, PostgreSQL, SQL Server, MongoDB, SQLite and others

    ## misc
    pueue
    neovim
    czkawka # Simple, fast and easy to use app to remove unnecessary files from your computer

    ## Build & Dev tools
    act # Run your GitHub Actions locally
    actionlint # Static checker for GitHub Actions workflow files
    bump # CLI tool to draft a GitHub Release for the next semantic version
    buildah # A tool which facilitates building OCI images
    buildkit # Concurrent, cache-efficient, and Dockerfile-agnostic builder toolkit
    buildkit-nix # Nix frontend for x
    buildkite-cli # A command line interface for Buildkite
    bun
    codeberg-cli
    #cargo
    go-task # Task runner / simpler Make alternative written in Go
    gh # github cli
    glab # gitlab cli
    geminicommit # CLI that generates git commit messages with Google Gemini AI
    git-interactive-rebase-tool
    jid # json editor
    jless # json editor
    just # build tool
    lazygit # Simple terminal UI for git commands
    pre-commit
    rustc
    rustup # Rust toolchain installer
    skaffold
    uv # Extremely fast Python package installer and resolver, written in Rust

    ### Linter and Formatter
    commitlint
    prettier # Code formatter
    prettier-plugin-go-template # Fixes prettier formatting for go templates
    vacuum-go # World's fastest OpenAPI & Swagger linter

    ### API
    bruno # Open-source IDE For exploring and testing APIs
    hurl # Command line tool that performs HTTP requests defined in a simple plain text format.
    insomnia # The most intuitive cross-platform REST API Client
    posting

    ### network
    aria2 # Lightweight, multi-protocol, multi-source, command-line download utility
    proton-vpn
    varia # Simple download manager based on aria2 and libadwaita

    ### Virtualization
    nemu # Ncurses UI for QEMU

    ### Storage
    goofys # A high-performance, POSIX-ish Amazon S3 file system written in Go
    gocryptfs # Encrypted overlay filesystem written in Go
    cryptor # Simple gocryptfs GUI
    steghide # Open source steganography program
    tomb # File encryption on GNU/Linux

    ## Terminal
    pay-respects
    gpg-tui # Terminal user interface for GnuPG
    timg # Terminal image and video viewer
    ticker # Terminal stock ticker with live updates and position tracking
    w3m # A text-mode web browser
    vhs # Tool for generating terminal GIFs with code
    yazi # terminal file explorer

    ### System tools
    erdtree # File-tree visualizer and disk usage analyzer
    lazyjournal

    ## Docker and Kubernetes
    dive # Tool for exploring each layer in a docker image
    popeye # Kubernetes cluster resource sanitizer

    ### IaC
    ansible
    ansible-lint
    terraform
    #terragrunt # A thin wrapper for Terraform that supports locking for Terraform state and enforces best practices
    terraform-docs # A utility to generate documentation from Terraform modules in various output formats
    tflint
    packer
    vagrant

    ### Cloud
    azure-cli
    python312Packages.msrest
    google-cloud-sdk
    hcloud # A command-line interface for Hetzner Cloud, a provider for cloud virtual private servers1
    ibmcloud-cli # Command line client for IBM Cloud
    python312Packages.hcloud # Library for the Hetzner Cloud API

    ## fun
    genact # Nonsense activity generator
    nms # A command line tool that recreates the famous data decryption effect seen in the 1992 movie Sneakers

    ## GNOME Stuff
    flameshot
    wike # Wikipedia Reader for the GNOME Desktop
    vte # Provides vte.2,91.typelib
    libhandy # Provides Handy-1.typelib
    gjs # JavaScript bindings for GNOME
    gtk-layer-shell # Library to create panels and other desktop components for Wayland using the Layer Shell protocol
    gnome-network-displays # miracast implementation for GNOME
    gnomeExtensions.keep-awake # Keep your computer awake! Prevents that your computer activates sceensaver, turns off screen(s) or goes to hibernate when not actively used for a while.
    gnomeExtensions.gsconnect
    gnomeExtensions.top-bar-organizer
    gnomeExtensions.topiconsfix # Shows legacy tray icons on top – the fixed version of https://extensions.gnome.org/extension/495/topicons/
    gnomeExtensions.campeek
    gnomeExtensions.tophat
    gnomeExtensions.paperwm
    gnomeExtensions.ddterm
    gnomeExtensions.status-area-horizontal-spacing # Reduce the horizontal spacing between icons in the top-right status area
    gnomeExtensions.burn-my-windows
    gnomeExtensions.veil
    gnomeExtensions.just-perfection # Tweak Tool to Customize GNOME Shell, Change the Behavior and Disable UI Elements
    gnomeExtensions.ip-finder # Displays useful information about your public IP Address and VPN status.
    gnomeExtensions.smart-home # This extension controls Philips Hue compatible lights using Philips Hue Bridge on your local network, it also allows controlling Philips Hue Sync Box. I
    gnomeExtensions.display-configuration-switcher # Quickly change the display configuration from the system menu.
    #gnomeExtensions.another-window-session-manager # Close open windows gracefully and save them as a session.
    #gnomeExtensions.sermon # SerMon: an extension for monitoring and managing systemd services, cron jobs, docker and podman containers
    #gnomeExtensions.window-state-manager # Automatically remember and restore window state and positions.
    wtype # xdotool type for wayland

    ### Comm
    element-desktop # A feature-rich client for Matrix.org
    irssi
    signal-desktop

    ### Browser, Mail, ...
    deluge
    mutt
    profile-sync-daemon
    evince
    vivaldi # browser
    poppler-utils # PDF
    nextcloud-client
    speechd # Common interface to speech synthesis
    morphosis # Convert your documents

    ## Media
    pinta
    gimp

    ## Google
    #gam # Command line management for Google Workspace
    gws # One CLI for all of Google Workspace
  ];

  # services.postgresql = {
  #   enable = true;
  #   package = pkgs.postgresql_17;
  #   enableTCPIP = true;
  #   # port = 5432;
  #   authentication = pkgs.lib.mkOverride 10 ''
  #     #...
  #     #type database DBuser origin-address auth-method
  #     local all       all     trust
  #     # ipv4
  #     host  all      all     127.0.0.1/32   trust
  #     # ipv6
  #     host all       all     ::1/128        trust
  #   '';
  # };
}
