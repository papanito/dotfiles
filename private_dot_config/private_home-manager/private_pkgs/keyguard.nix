# Keyguard — official prebuilt Linux release instead of nixpkgs' lagging source
# build (nixpkgs was at 2.3.4 while upstream is 3.7.0; a nixpkgs-style bump
# would require regenerating the Gradle deps.json via mitm proxy — use the
# official binary until nixpkgs catches up).
{ pkgs, lib }:

pkgs.stdenv.mkDerivation rec {
  pname = "keyguard";
  version = "3.7.0";
  src = pkgs.fetchurl {
    url = "https://github.com/AChep/keyguard-app/releases/download/r20261103/Keyguard-${version}-linux-x86_64.tar.gz";
    sha256 = "sha256-zzH3cbFnr9yzz+vd63QIsIqjpD/+kI8v7epcN69m/t0=";
  };
  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    pkgs.copyDesktopItems
    # Keyguard dlopens a theme lib it extracts to ~/.cache/nucleus at
    # runtime; autoPatchelf cannot see that file, so the libdbus-1.so.3
    # dependency must reach it via the launcher's LD_LIBRARY_PATH (wrapProgram
    # below). Without it the app crashes seconds after start ("UnsatisfiedLinkError
    # ... libdbus-1.so.3"), which also kills the SSH agent it hosts.
    pkgs.makeWrapper
  ];
  buildInputs = [
    pkgs.fontconfig
    pkgs.libxinerama
    pkgs.libxrandr
    # X11 libs required by the bundled JDK runtime (libawt_xawt.so requests
    # libXtst.so.6 directly, which is not propagated by the other inputs)
    pkgs.libXtst
    pkgs.libXi
    pkgs.libXrender
    pkgs.file
    pkgs.gtk3
    pkgs.glib
    pkgs.cups
    pkgs.lcms2
    pkgs.alsa-lib
    pkgs.libglvnd
  ];
  sourceRoot = "Keyguard";
  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "keyguard";
      exec = "Keyguard";
      icon = "keyguard";
      desktopName = "Keyguard";
    })
  ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp --recursive . $out
    install -D --mode=0644 lib/Keyguard.png $out/share/icons/hicolor/512x512/apps/keyguard.png

    # Inject libdbus for the runtime-dlopened nucleus theme lib (see
    # nativeBuildInputs note). The launcher passes its env to the JVM.
    wrapProgram $out/bin/Keyguard \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.dbus.lib ]}

    # wrapProgram renames the ELF launcher to .Keyguard-wrapped, and the
    # jpackage launcher derives its options-file name from its own exe
    # basename (/proc/self/exe): it then looks for lib/app/.Keyguard-wrapped.cfg,
    # but the tarball only ships lib/app/Keyguard.cfg (named after the plain
    # launcher). Without this copy the app aborts at every launch
    # ("Error opening ... .Keyguard-wrapped.cfg"), silently taking the
    # hosted SSH agent down with it (Keyguard 3.7.0, 2026-11-21).
    cp --no-preserve=mode $out/lib/app/Keyguard.cfg $out/lib/app/.Keyguard-wrapped.cfg

    runHook postInstall
  '';
  meta = {
    description = "Alternative client for the Bitwarden platform, created to provide the best user experience possible";
    homepage = "https://github.com/AChep/keyguard-app";
    mainProgram = "Keyguard";
    # Official release runs under a proprietary license
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
  };
}
