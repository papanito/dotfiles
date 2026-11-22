# rwx (vncsmnl/rwx): interactive TUI for Unix file permissions/ownership.
# Not in nixpkgs (verified by full-tree `nix search`) and upstream ships no
# flake; the release tag has a committed Cargo.lock, so vendoring is a
# two-hash bump (src + cargoHash, fakeHash two-step build). Upstream unit
# tests run in the sandbox and pass.
{ pkgs, lib }:

pkgs.rustPlatform.buildRustPackage {
  pname = "rwx";
  version = "1.0.6";

  src = pkgs.fetchFromGitHub {
    owner = "vncsmnl";
    repo = "rwx";
    rev = "v1.0.6";
    hash = "sha256-68940nad2tdWJF8mBGa55GVd/Jap0hu4Mq8zDUYE30Q=";
  };
  cargoHash = "sha256-WLB/TEeM8Z3E6AiC8dmJa1Wtax6tN7l72U3zcFSSLb4=";

  meta = {
    description = "Interactive Unix file permissions and ownership TUI manager";
    homepage = "https://github.com/vncsmnl/rwx";
    license = lib.licenses.mit;
    mainProgram = "rwx";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
