{
  description = "My Home Manager configuration";

  inputs = {
    # Nixpkgs provides the packages and modules for your system.
    # You can pin to a specific release (e.g., "nixos-24.05") or unstable.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";

    # Home Manager itself
    home-manager = {
      url = "github:nix-community/home-manager";
      # Ensure Home Manager uses the same Nixpkgs as your flake for consistency.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pi-nix = {
      url = "github:lukasl-dev/pi.nix";
    };

    omp-nix.url = "github:cernoh/omp-flake";
    sheets.url = "github:maaslalani/sheets";
    herdr.url = "github:ogulcancelik/herdr";
    # You can add other flakes as inputs here, e.g., custom overlays or utility flakes.
    # flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      home-manager,
      pi-nix,
      omp-nix,
      herdr,
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
        };
        overlays = [
          (final: prev: {
            # inline-snapshot has 3 flaky test failures in nixpkgs unstable
            # that block the entire home-manager build. Disable its tests.
            python312Packages = prev.python312Packages.overrideScope (pyFinal: pyPrev: {
              inline-snapshot = pyPrev.inline-snapshot.overridePythonAttrs (_: {
                doCheck = false;
              });
            });
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
          ./modules/ollama.nix
          ./modules/llama-cpp.nix
          ./modules/omniroute.nix
        ];
        extraSpecialArgs = {
          inherit
            inputs
            home_attrs
            pi-nix
            omp-nix
            herdr
            ;
        };
        # Optionally, pass extra arguments to your home.nix
        # extraSpecialArgs = {
        #   myCustomArg = "some-value";
        # };
      };
    };
}
