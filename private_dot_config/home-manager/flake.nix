{
  description = "My Home Manager configuration";

  inputs = {
    # Nixpkgs provides the packages and modules for your system.
    # You can pin to a specific release (e.g., "nixos-24.05") or unstable.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager itself
    home-manager = {
      url = "github:nix-community/home-manager";
      # Ensure Home Manager uses the same Nixpkgs as your flake for consistency.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:nix-community/nixGL";
    quickshell = {
      url = "github:quickshell-mirror/quickshell/db1777c20b936a86528c1095cbcb1ebd92801402";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # You can add other flakes as inputs here, e.g., custom overlays or utility flakes.
    # flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, nixgl, quickshell,  ... }:
    let
      home_attrs = rec {
        #username = import ./username.nix;
        username = "papanito";
        homeDirectory = "/home/${username}";
        # Do not edit stateVersion value, see https://github.com/nix-community/home-manager/issues/5794
        stateVersion = "25.05";
      };
      # Define your system architecture.
      system = "x86_64-linux"; # Or "aarch64-darwin" for macOS, etc.

      # Create a pkgs instance for your system.
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true; # Set to true if you need unfree packages
          # Add any other nixpkgs configuration here
        };
      };
    in {
      # This is the primary output for standalone Home Manager.
      # You can also use homeConfigurations."${builtins.getEnv "USER"}" or similar
      # for more dynamic user names.
      homeConfigurations."papanito" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # Specify your Home Manager configuration modules here.
        # This typically points to a home.nix file.
        modules = [
          ./home.nix
          #./dots_hyperland.nix
          ./modules/gnome.nix
        ];
        extraSpecialArgs = { inherit home_attrs nixgl quickshell; };
        # Optionally, pass extra arguments to your home.nix
        # extraSpecialArgs = {
        #   myCustomArg = "some-value";
        # };

      };
    };
}
