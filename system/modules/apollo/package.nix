# Apollo (https://github.com/ClassicOldSong/Apollo), a Sunshine fork.
# Not in nixpkgs, so this is adapted from the nixpkgs sunshine recipe.
# The binary is still called `sunshine`.
{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  makeWrapper,
  buildNpmPackage,
  cmake,
  pkg-config,
  python3,
  wayland-scanner,
  coreutils,
  avahi,
  libevdev,
  libpulseaudio,
  libx11,
  libxcb,
  libxfixes,
  libxrandr,
  libxtst,
  libxi,
  libxdmcp,
  openssl,
  libopus,
  boost189,
  libdrm,
  wayland,
  libffi,
  libcap,
  libgbm,
  curl,
  pcre2,
  libuuid,
  libselinux,
  libsepol,
  libthai,
  libdatrie,
  libxkbcommon,
  libepoxy,
  libva,
  libvdpau,
  libglvnd,
  numactl,
  amf-headers,
  svt-av1,
  libayatana-appindicator,
  glib,
  libsysprof-capture,
  gtk3,
  libnotify,
  miniupnpc,
  nlohmann_json,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "apollo";
  version = "0.4.6-unstable-2026-05-21";

  src = fetchFromGitHub {
    owner = "ClassicOldSong";
    repo = "Apollo";
    rev = "adc5c5a0bd80831ce495434bb16aee2cd4175fb8";
    hash = "sha256-2HKjpv/NK8eMq4fUC6sFSfSDSIvT8crP//MMDoF/Bxs=";
    fetchSubmodules = true;
  };

  # build webui
  ui = buildNpmPackage {
    inherit (finalAttrs) src version;
    pname = "apollo-ui";
    npmDepsHash = "sha256-PJMS3ty7/BxD4DnSTq+EsEXTV4viR9qaEOAN7nHz+3w=";

    # upstream doesn't ship a lockfile
    postPatch = ''
      cp ${./package-lock.json} package-lock.json
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -a . "$out"/

      runHook postInstall
    '';
  };

  postPatch = ''
    # don't look for npm since we build webui separately
    substituteInPlace cmake/targets/common.cmake \
      --replace-fail 'find_program(NPM npm REQUIRED)' ""

    # Boost.System is header-only and no longer ships a library/cmake component
    sed -i '/^        system$/d' cmake/dependencies/Boost_Sunshine.cmake
    substituteInPlace third-party/Simple-Web-Server/CMakeLists.txt \
      --replace-fail 'find_package(Boost 1.53.0 COMPONENTS system REQUIRED)' 'find_package(Boost 1.53.0 REQUIRED)' \
      --replace-fail 'Boost::boost Boost::system' 'Boost::boost'

    # remove upstream dependency on systemd and udev
    substituteInPlace cmake/packaging/linux.cmake \
      --replace-fail 'find_package(Systemd)' "" \
      --replace-fail 'find_package(Udev)' ""

    substituteInPlace packaging/linux/dev.lizardbyte.app.Sunshine.desktop \
      --replace-fail '/usr/bin/env systemctl start --u sunshine' 'sunshine'

    substituteInPlace packaging/linux/sunshine.service.in \
      --replace-fail '/bin/sleep' '${lib.getExe' coreutils "sleep"}'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    python3
    makeWrapper
    wayland-scanner
    # Avoid fighting upstream's usage of vendored ffmpeg libraries
    autoPatchelfHook
  ];

  buildInputs = [
    avahi
    libevdev
    libpulseaudio
    libx11
    libxcb
    libxfixes
    libxrandr
    libxtst
    libxi
    openssl
    libopus
    boost189
    libdrm
    wayland
    libffi
    libcap
    curl
    pcre2
    libuuid
    libselinux
    libsepol
    libthai
    libdatrie
    libxdmcp
    libxkbcommon
    libepoxy
    libva
    libvdpau
    numactl
    libgbm
    amf-headers
    svt-av1
    libayatana-appindicator
    glib
    libsysprof-capture
    gtk3
    libnotify
    miniupnpc
    nlohmann_json
  ];

  runtimeDependencies = [
    avahi
    libgbm
    libxrandr
    libxcb
    libglvnd
  ];

  cmakeFlags = [
    "-Wno-dev"
    # upstream tries to use systemd and udev packages to find these directories in FHS; set the paths explicitly instead
    (lib.cmakeBool "UDEV_FOUND" true)
    (lib.cmakeBool "SYSTEMD_FOUND" true)
    (lib.cmakeFeature "UDEV_RULES_INSTALL_DIR" "lib/udev/rules.d")
    (lib.cmakeFeature "SYSTEMD_USER_UNIT_INSTALL_DIR" "lib/systemd/user")
    (lib.cmakeFeature "SYSTEMD_MODULES_LOAD_DIR" "lib/modules-load.d")
    (lib.cmakeBool "BOOST_USE_STATIC" false)
    (lib.cmakeBool "BUILD_DOCS" false)
    (lib.cmakeBool "SUNSHINE_ENABLE_CUDA" false)
  ];

  env = {
    # needed to trigger CMake version configuration
    BUILD_VERSION = finalAttrs.version;
    BRANCH = "master";
    COMMIT = finalAttrs.src.rev;
  };

  # copy webui where it can be picked up by build
  preBuild = ''
    cp -r ${finalAttrs.ui}/build ../
  '';

  buildFlags = [ "sunshine" ];

  # redefine installPhase to avoid attempt to build webui
  installPhase = ''
    runHook preInstall

    cmake --install .

    runHook postInstall
  '';

  meta = {
    description = "Sunshine fork: game stream host for Artemis/Moonlight";
    homepage = "https://github.com/ClassicOldSong/Apollo";
    license = lib.licenses.gpl3Only;
    mainProgram = "sunshine";
    platforms = [ "x86_64-linux" ];
  };
})
