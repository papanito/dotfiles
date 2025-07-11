{  pkgs, lib, config, security, ... }:
let 
    mountdir_yunohost = "${config.home.homeDirectory}/cs/yuno";
in
{
  home = {
    username = "papanito";
    homeDirectory = "/home/papanito";
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };

  # Set the state version for Home Manager. This helps with Wmigrations.
  # Check the Home Manager manual for the recommended version for your Nixpkgs.
  home.stateVersion = "25.05"; # Example, align with your nixpkgs release

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  home.packages = with pkgs; [
    esbuild
    act # Run your GitHub Actions locally
    actionlint # Static checker for GitHub Actions workflow files
    bump # CLI tool to draft a GitHub Release for the next semantic version
    #doppler # The official CLI for interacting with your Doppler Enclave secrets and configuration
    pueue
    bruno # Open-source IDE For exploring and testing APIs
    buildah # A tool which facilitates building OCI images
    buildkit # Concurrent, cache-efficient, and Dockerfile-agnostic builder toolkit
    buildkit-nix #Nix frontend for x
    buildkite-cli # A command line interface for Buildkite
    dbeaver-bin # Universal SQL Client for developers, DBA and analysts. Supports MySQL, PostgreSQL, MariaDB, SQLite, and more
    dbgate # Database manager for MySQL, PostgreSQL, SQL Server, MongoDB, SQLite and others
    #hurl #Command line tool that performs HTTP requests defined in a simple plain text format.
    #gnome-boxes
    #cockpit # Web-based graphical interface for servers
    #darling # Open-source Darwin/macOS emulation layer for Linux
    insomnia # The most intuitive cross-platform REST API Client
    just # A handy way to save and run project-specific commands
    gemini-cli # AI agent that brings the power of Gemini
    geminicommit # CLI that generates git commit messages with Google Gemini AI
    gh # github cli
    glab # gitlab cli
    gitleaks # Scan git repos (or files) for secrets
    goofys # A high-performance, POSIX-ish Amazon S3 file system written in Go
    hugo # A fast and modern static website engine
    pay-respects
    poppler # A PDF rendering library
    posting
    skaffold
    shellcheck # Shell script analysis tool
    xorriso
    trivy
    uv #Extremely fast Python package installer and resolver, written in Rust
    cryfs # Cryptographic filesystem for the cloud
    tomb # File encryption on GNU/Linux
    steghide #Open source steganography program
    wrangler_1 # A CLI tool designed for folks who are interested in using Cloudflare Workers
    timg # Terminal image and video viewer
    w3m # A text-mode web browser
    ticker # Terminal stock ticker with live updates and position tracking
    vivaldi
    rssguard
    vhs # Tool for generating terminal GIFs with code
    lutris # Open Source gaming platform for GNU/Linux

    ## fun
    genact # Nonsense activity generator
    nms # A command line tool that recreates the famous data decryption effect seen in the 1992 movie Sneakers

    # gnome extensions
    gnomeExtensions.bing-wallpaper-changer
    gnomeExtensions.keep-awake # Keep your computer awake! Prevents that your computer activates sceensaver, turns off screen(s) or goes to hibernate when not actively used for a while. 
    gnomeExtensions.gsconnect
    gnomeExtensions.top-bar-organizer
    gnomeExtensions.topiconsfix # Shows legacy tray icons on top – the fixed version of https://extensions.gnome.org/extension/495/topicons/
    gnomeExtensions.tophat
    gnomeExtensions.status-area-horizontal-spacing # Reduce the horizontal spacing between icons in the top-right status area
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
    gnomeExtensions.window-state-manager # Automatically remember and restore window state and positions. U
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
      mount-yunohost = {
          Unit = {
              Description = "mount yunohost home";
          };
          Mount = {
            What="adrian@yuno.home:/home";
            Where="${mountdir_yunohost}";
            Type="sshfs";
            Options="x-systemd.automount,_netdev,reconnect,allow_other,identityfile=/home/papanito/.ssh/id_rsa";
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