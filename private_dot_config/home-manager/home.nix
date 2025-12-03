{  pkgs, lib, config, nixgl, quickshell, home_attrs, security, ... }:
let 
  mountdir_yunohost = "${config.home.homeDirectory}/cs/yuno";
  my-python-packages = ps: with ps; [
    pandas
    requests
    pip # The PyPA recommended tool for installing Python packages
    django
    pillow # The friendly PIL fork (Python Imaging Library)
    jupyter # A high-level dynamically-typed programming language
    notebook # Web-based notebook environment for interactive computing
  ];
  my-nodes-packages = ns: with ns; [
    gemini-cli
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
  home.stateVersion = "25.05"; # Example, align with your nixpkgs release

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  home.packages = with pkgs; [
    (pkgs.python3.withPackages my-python-packages)
    lazyjournal
    pueue
    #cockpit # Web-based graphical interface for servers
    hugo # A fast and modern static website engine
    poppler-utils #PDF
    trivy
    lutris # Open Source gaming platform for GNU/Linux
    nextcloud-client
    speechd # Common interface to speech synthesis
    goto # easy to use terminal SSH manager with advanced features. Binaries included!
    
    ### Browser, Mail, ...
    mutt
    element-desktop # A feature-rich client for Matrix.org
    signal-desktop-bin
    profile-sync-daemon
    deluge
    irssi
    evince
    ollama
    #rpi-imager
    rssguard
    vivaldi # browser

    ### API
    bruno # Open-source IDE For exploring and testing APIs
    hurl #Command line tool that performs HTTP requests defined in a simple plain text format.
    insomnia # The most intuitive cross-platform REST API Client
    posting
    aria2 # Lightweight, multi-protocol, multi-source, command-line download utility
    varia # Simple download manager based on aria2 and libadwaita

    ### Storage
    cryfs # Cryptographic filesystem for the cloud
    goofys # A high-performance, POSIX-ish Amazon S3 file system written in Go
    gocryptfs # Encrypted overlay filesystem written in Go
    cryptor # Simple gocryptfs GUI
    vaults # GTK frontend for encrypted vaults supporting gocryptfs and CryFS for encryptiongocryptfs
    steghide #Open source steganography program
    tomb # File encryption on GNU/Linux

    ## Terminal
    nix-direnv # A fast, persistent use_nix implementation for direnv
    pay-respects
    gpg-tui # Terminal user interface for GnuPG
    timg # Terminal image and video viewer
    w3m # A text-mode web browser
    ticker # Terminal stock ticker with live updates and position tracking
    vhs # Tool for generating terminal GIFs with code
    yazi # terminal file explorer

    ## Docker and Kubernetes
    dive # Tool for exploring each layer in a docker image

    ## Cloud
    ansible
    ansible-lint
    azure-cli
    python312Packages.msrest
    google-cloud-sdk
    hcloud # A command-line interface for Hetzner Cloud, a provider for cloud virtual private servers1
    ibmcloud-cli # Command line client for IBM Cloud
    python312Packages.hcloud # Library for the Hetzner Cloud API
    terraform
    terragrunt # A thin wrapper for Terraform that supports locking for Terraform state and enforces best practices
    #terraform-docs # A utility to generate documentation from Terraform modules in various output formats
    tflint 
    packer
    vagrant
    
    ## Development
    act # Run your GitHub Actions locally
    actionlint # Static checker for GitHub Actions workflow files
    bump # CLI tool to draft a GitHub Release for the next semantic version
    buildah # A tool which facilitates building OCI images
    buildkit # Concurrent, cache-efficient, and Dockerfile-agnostic builder toolkit
    buildkit-nix #Nix frontend for x
    buildkite-cli # A command line interface for Buildkite
    dbeaver-bin # Universal SQL Client for developers, DBA and analysts. Supports MySQL, PostgreSQL, MariaDB, SQLite, and more
    dbgate # Database manager for MySQL, PostgreSQL, SQL Server, MongoDB, SQLite and others
    shellcheck # Shell script analysis tool
    skaffold
    wrangler_1 # A CLI tool designed for folks who are interested in using Cloudflare Workers
    uv #Extremely fast Python package installer and resolver, written in Rust
    gemini-cli # AI agent that brings the power of Gemini
    geminicommit # CLI that generates git commit messages with Google Gemini AI
    gh # github cli
    glab # gitlab cli
    gitleaks # Scan git repos (or files) for secrets
    gradle
    go-task # Task runner / simpler Make alternative written in Go
    ghostty # terminal
    neovim
    lazygit # Simple terminal UI for git commands
    maven
    rs-git-fsmonitor # Fast git core.fsmonitor hook
    vscodium # Open source source code editor developed by Microsoft for Windows, Linux and macOS (VS Code without MS branding/telemetry/licensing)
    nodePackages.zx # A tool for writing better scripts.
    nodePackages.snyk # snyk library and cli utility
    # obsidian # A powerful knowledge base that works on top of a local folder of plain text Markdown files
    
    ## fun
    genact # Nonsense activity generator
    nms # A command line tool that recreates the famous data decryption effect seen in the 1992 movie Sneakers

    ## GNOME Stuff
    wike # Wikipedia Reader for the GNOME Desktop
    gnome-network-displays # miracast implementation for GNOME
    gnomeExtensions.tailscale-qs # Add Tailscale to GNOME quick settings
    gnomeExtensions.bing-wallpaper-changer
    gnomeExtensions.keep-awake # Keep your computer awake! Prevents that your computer activates sceensaver, turns off screen(s) or goes to hibernate when not actively used for a while. 
    gnomeExtensions.gsconnect
    gnomeExtensions.top-bar-organizer
    gnomeExtensions.topiconsfix # Shows legacy tray icons on top – the fixed version of https://extensions.gnome.org/extension/495/topicons/
    #gnomeExtensions.tophat
    gnomeExtensions.status-area-horizontal-spacing # Reduce the horizontal spacing between icons in the top-right status area
    gnomeExtensions.burn-my-windows
    gnomeExtensions.lilypad # Organize, hide, and reorder top bar icons
    #gnomeExtensions.window-state-manager
    gnomeExtensions.power-profile-switcher # Automatically switch between power profiles based on power supply and percentage.
    gnomeExtensions.just-perfection # Tweak Tool to Customize GNOME Shell, Change the Behavior and Disable UI Elements
    gnomeExtensions.ip-finder # Displays useful information about your public IP Address and VPN status.
    gnomeExtensions.tuxedo-fnlock-status # Show the FnLock status of TUXEDO devices.
    gnomeExtensions.battery-health-charging # Set battery charging threshold / charging limit / charging mode
    gnomeExtensions.hue-lights # This extension controls Philips Hue compatible lights using Philips Hue Bridge on your local network, it also allows controlling Philips Hue Sync Box. I
    gnomeExtensions.forge # Tiling and window manager for GNOME
    gnomeExtensions.display-configuration-switcher # Quickly change the display configuration from the system menu.
    gnomeExtensions.another-window-session-manager # Close open windows gracefully and save them as a session. 
    gnomeExtensions.window-state-manager # Automatically remember and restore window state and positions.
    gnomeExtensions.dash-to-panel

    ## Media
    pinta
    gimp
    #gimpPlugins.gap
    gimpPlugins.gmic
    #gimpPlugins.bimp
    #gimpPlugins.fourier
    #gimpPlugins.texturize
    #gimpPlugins.lqrPlugin
    #gimpPlugins.lightning
    #gimpPlugins.gimplensfun
    #gimpPlugins.waveletSharpen

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

  systemd.user = {
    mounts = {
      mount-envymedia = {
          Unit = {
              Description = "mount mediacenter media";
          };
          Mount = {
            What="admin@10.0.0.10:/media";
            Where="${mountdir_yunohost}";
            Type="sshfs";
            Options="x-systemd.automount,_netdev,reconnect,allow_other,identityfile=/home/papanito/.ssh/admin@envy.pub";
            #SloppyOptions=
            #LazyUnmount=
            #ReadWriteOnly=
            #ForceUnmount=
            #DirectoryMode=
            #TimeoutSec=
          };
      };
    };
    # services = {
    #   pueued = {
    #     enable = true;
    #     description = "Pueue daemon";

    #     # wantedBy = [ "multi-user.target" ];

    #     # restartIfChanged = true; # set to false, if restarting is problematic

    #     # serviceConfig = {
    #     #   DynamicUser = true;
    #     #   ExecStart = "/run/current-system/sw/bin/pueued -dv";
    #     #   Restart = "always";
    #     # };
    #   };
    # };
  };

 
  
}
