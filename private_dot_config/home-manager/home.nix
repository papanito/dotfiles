{  pkgs, lib, config, security, ... }:
let 
    mountdir_yunohost = "${config.home.homeDirectory}/cs/yuno";
in
{
  home = {
    username = "papanito";
    homeDirectory = "/home/papanito";
  };

  # modules
  gnome.enable = false;
  kde.enable = true;

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
  home.stateVersion = "25.11"; # Example, align with your nixpkgs release

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  home.packages = with pkgs; [
    act # Run your GitHub Actions locally
    actionlint # Static checker for GitHub Actions workflow files
    bump # CLI tool to draft a GitHub Release for the next semantic version
    #doppler # The official CLI for interacting with your Doppler Enclave secrets and configuration
    sshfs
    pueue
    bruno # Open-source IDE For exploring and testing APIs
    buildah # A tool which facilitates building OCI images
    buildkit # Concurrent, cache-efficient, and Dockerfile-agnostic builder toolkit
    buildkit-nix #Nix frontend for BuildKit
    buildkite-cli # A command line interface for Buildkite
    dbeaver-bin # Universal SQL Client for developers, DBA and analysts. Supports MySQL, PostgreSQL, MariaDB, SQLite, and more
    dbgate # Database manager for MySQL, PostgreSQL, SQL Server, MongoDB, SQLite and others
    #hurl #Command line tool that performs HTTP requests defined in a simple plain text format.
    #gnome-boxes
    #cockpit # Web-based graphical interface for servers
    #darling # Open-source Darwin/macOS emulation layer for Linux
    insomnia # The most intuitive cross-platform REST API Client
    just # A handy way to save and run project-specific commands
    gh # github cli
    glab # gitlab cli
    gitleaks # Scan git repos (or files) for secrets
    hugo # A fast and modern static website engine
    pay-respects
    #poppler # A PDF rendering library
    #poppler_utils # A PDF rendering library
    posting
    skaffold
    shellcheck # Shell script analysis tool
    xorriso
    trivy
    uv #Extremely fast Python package installer and resolver, written in Rust
    cryfs # Cryptographic filesystem for the cloud
    tomb # File encryption on GNU/Linux
    steghide #Open source steganography program
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