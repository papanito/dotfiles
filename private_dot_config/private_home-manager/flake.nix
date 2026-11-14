{
  description = "My Home Manager configuration";

  inputs = {
    # Nixpkgs is pinned to the exact rev the system flake (/etc/nixos) locks
    # (nixos-26.05, 26.05.20261105.c56a87d).
    #
    # This is not cosmetic: the GNOME session exports GI_TYPELIB_PATH pointing
    # at the system's glib typelibs, so a home-manager `gjs` built from a
    # different nixpkgs loads a foreign libgio and aborts on `import Gio`
    # (duplicate GOutputStream/GPollableOutputStream GTypes, "gtype !=
    # G_TYPE_INVALID"). Same rev => same store path => no mismatch.
    # Bump this rev together with the nixpkgs input in /etc/nixos/flake.lock.
    nixpkgs.url = "github:NixOS/nixpkgs/c56a87d8e41ce69bd2af57eb35dcc117a9dfca33";
    sops-nix.url = "github:Mic92/sops-nix";

    # Home Manager itself. Pinned to the same release branch as the system
    # flake's home-manager input (/etc/nixos/flake.nix); master expects an
    # unstable nixpkgs, which we no longer track here.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      # Ensure Home Manager uses the same Nixpkgs as your flake for consistency.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix packages for AI coding agents / agent tooling, auto-updated daily.
    # Follows our (now 26.05-pinned) nixpkgs. Upstream documents a "reasonably
    # current unstable" as the tested base — if an llm-agents build breaks,
    # give this input its own nixpkgs instead of unpinning the global one
    # (that would reintroduce the gjs/GI_TYPELIB_PATH closure mismatch).
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pi-nix.url = "github:lukasl-dev/pi.nix";
    omp-nix.url = "github:cernoh/omp-flake";
    sheets.url = "github:maaslalani/sheets";
    herdr.url = "github:ogulcancelik/herdr";
    gwl.url = "github:kbrdn1/gwm-cli";
    iris.url = "github:versenilvis/iris/main";
    # You can add other flakes as inputs here, e.g., custom overlays or utility flakes.
    # flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      home-manager,
      llm-agents,
      pi-nix,
      omp-nix,
      herdr,
      gwl,
      iris,
      ...
    }@inputs:
    let
      home_attrs = rec {
        #username = import ./username.nix;
        username = "papanito";
        homeDirectory = "/home/${username}";
        # Do not ediok soundt stateVersion value, see https://github.com/nix-community/home-manager/issues/5794
        stateVersion = "unstable";
      };
      # Define your system architecture.
      system = "x86_64-linux"; # Or "aarch64-darwin" for macOS, etc.

      # Create a pkgs instance for your system.
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          # libguestfs (virt-manager dependency) is marked broken in current
          # nixpkgs unstable; permit evaluation until it is fixed upstream.
          problems.handlers = {
            libguestfs.broken = "warn";
          };
        };
        overlays = [
          llm-agents.overlays.shared-nixpkgs
          (final: prev: {
            # inline-snapshot has 3 flaky test failures in nixpkgs unstable
            # that block the entire home-manager build. Disable its tests.
            python312Packages = prev.python312Packages.overrideScope (
              pyFinal: pyPrev: {
                inline-snapshot = pyPrev.inline-snapshot.overridePythonAttrs (_: {
                  doCheck = false;
                });
              }
            );
          })
        ];
      };
    in
    {
      # This is the primary output for standalone Home Manager.
      # You can also use homeConfigurations."${builtins.getEnv "USER"}" or similar
      # for more dynamic user names.
      homeConfigurations."papanito" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # Specify your Home Manager configuration modules here.
        modules = [
          ./home.nix
          ./modules/paperless-sync.nix
          ./modules/watchman.nix
          ./modules/pueue.nix
          ./modules/gnome.nix
          ./modules/llm-agents.nix
          ./modules/ollama.nix
          ./modules/tuios.nix
          ./modules/llama-cpp.nix
          ./modules/omniroute.nix
          ./modules/opencode.nix
          ./modules/voxtype.nix
          inputs.sops-nix.homeManagerModules.sops # Added this line
        ];
        extraSpecialArgs = {
          inherit
            inputs
            home_attrs
            pi-nix
            omp-nix
            herdr
            gwl
            iris
            ;
        };
        # Optionally, pass extra arguments to your home.nix
        # extraSpecialArgs = {
        #   myCustomArg = "some-value";
        # };
      };
    };
}
