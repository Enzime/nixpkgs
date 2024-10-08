{ stdenv, lib, fetchFromGitHub, fetchzip, fetchurl, cmake, ninja, pkg-config, python3
, fmt, openblas, mbrola, espeak, boost, stt, onnxruntime
, piper-phonemize, spdlog, piper, python312Packages, rnnoise, rhvoice
, qt5, libsForQt5, perl, opencl-headers, ocl-icd, amdvlk, cudaPackages
, pcre2, extra-cmake-modules, libpulseaudio
}:

let
  ssplitcpp = stdenv.mkDerivation {
    pname = "ssplitcpp";
    version = "unstable-2022-04-12"; # The package has no releases or tags

    src = fetchFromGitHub {
      owner = "ugermann";
      repo = "ssplit-cpp";
      rev = "49a8e12f11945fac82581cf056560965dcb641e6";
      hash = "sha256-ZmymCokVMbPbadAtun/7O8flbkFJcsQfI5YLSr0+6Ao=";
    };

    nativeBuildInputs = [ cmake ninja ];
    buildInputs = [ pcre2 ];

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
      "-DSSPLIT_COMPILE_LIBRARY_ONLY=ON"
      "-DSSPLIT_PREFER_STATIC_COMPILE=ON"
      "-DBUILD_SHARED_LIBS=OFF"
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/lib
      cp ssplit $out/bin
      cp libssplit.a $out/lib
      # cmake --install . "--prefix=$out"
      runHook postInstall
    '';

    meta = with lib; {
      description = "C++ library for sentence splitting";
      homepage = "https://github.com/ugermann/ssplit-cpp";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };

  vosk = stdenv.mkDerivation (finalAttrs: {
    pname = "vosk";
    version = "0.3.45"; # Not the latest version, but the one from the flatpack builder manifest

    src = fetchzip {
      url = if stdenv.hostPlatform.system == "x86_64-linux" then
        "https://github.com/alphacep/vosk-api/releases/download/v${finalAttrs.version}/vosk-linux-x86_64-${finalAttrs.version}.zip"
      else if stdenv.hostPlatform.system == "aarch64-linux" then
        "https://github.com/alphacep/vosk-api/releases/download/v${finalAttrs.version}/vosk-linux-aarch64-${finalAttrs.version}.zip"
        else
        throw "Unsupported system: ${stdenv.hostPlatform.system}";
      hash = if stdenv.hostPlatform.system == "x86_64-linux" then
        "sha256-ToMDbD5ooFMHU0nNlfpLynF29kkfMknBluKO5PipLFY="
        else
        "";
    };

    installPhase = ''
      mkdir -p $out/lib $out/include
      cp libvosk.so $out/lib
      cp vosk_api.h $out/include
    '';

    meta = with lib; {
      description = "Offline speech recognition API";
      homepage = "https://github.com/alphacep/vosk-api";
      license = licenses.asl20;
      platforms = [ "x86_64-linux" "aarch64-linux" ];
    };
  });

  webrtcvad = stdenv.mkDerivation {
    pname = "webrtcvad";
    version = "unstable-2024-09-29";

    src = fetchFromGitHub {
      owner = "webrtc-mirror";
      repo = "webrtc";
      rev = "ac87c8df2780cb12c74942ec8a473718c76cb5b7";
      hash = "sha256-BiFPuLi1r/ohDbUPOvp+kWZ5S7e40wzuvrdE31eHcHM=";
    };

    nativeBuildInputs = [ cmake ninja ];

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    ];

    patches = [
      (fetchurl {
        url = "https://github.com/mkiol/dsnote/raw/48050943e090028b9cffe592643ed21e756a2858/patches/webrtcvad.patch";
        hash = "sha256-4V5M9PpKTpwKESPRKh5gtFEFjMv5AdUJfk+P/6Q7XjY=";
      })
    ];

    meta = with lib; {
      description = "WebRTC Voice Activity Detector";
      homepage = "https://github.com/webrtc-mirror/webrtc";
      platforms = platforms.linux;
    };
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "dsnote";
  version = "4.6.1";

  src = fetchFromGitHub {
    owner = "mkiol";
    repo = "dsnote";
    rev = "v${finalAttrs.version}";
    hash = "sha256-kQNy8Lz+inkYN1wFjJ9p7s6sFcktV3OXE1I202E6xXg=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
    qt5.wrapQtAppsHook
    extra-cmake-modules
  ];

  buildInputs = [
    libpulseaudio
    fmt
    openblas
    mbrola
    espeak
    boost
    webrtcvad
    stt
    vosk
    onnxruntime
    piper-phonemize
    spdlog
    piper
    ssplitcpp
    python312Packages.pybind11
    rnnoise
    rhvoice
    qt5.qtbase
    qt5.qtdeclarative
    libsForQt5.qt5.qttools
    libsForQt5.qt5.qtmultimedia
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtx11extras
    libsForQt5.kdbusaddons
    perl
    opencl-headers
    ocl-icd
    # amdvlk
    # cudaPackages.nvidia_driver
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    "-DWITH_DESKTOP=ON"
    "-DDOWNLOAD_LIBSTT=OFF"
    "-DBUILD_VOSK=OFF"
    "-DBUILD_LIBARCHIVE=OFF"
    "-DBUILD_FMT=OFF"
    "-DBUILD_WHISPERCPP=OFF"
    "-DBUILD_WEBRTCVAD=OFF"
    "-DBUILD_OPENBLAS=OFF"
    "-DBUILD_XZ=OFF"
    "-DBUILD_RNNOISE=OFF"
    "-DBUILD_PYBIND11=OFF"
    "-DBUILD_PYTHON_MODULE=OFF"
    "-DBUILD_ESPEAK=OFF"
    "-DBUILD_PIPER=OFF"
    "-DBUILD_SSPLITCPP=OFF"
    "-DBUILD_RHVOICE=OFF"
    "-DBUILD_BERGAMOT=OFF"
    "-DBUILD_UROMAN=OFF"
    "-DBUILD_RUBBERBAND=OFF"
    "-DBUILD_FFMPEG=OFF"
    "-DBUILD_TAGLIB=OFF"
    "-DBUILD_LIBNUMBERTEXT=OFF"
    "-DBUILD_QHOTKEY=OFF"
    "-DBUILD_APRILASR=OFF"
    "-DBUILD_HTML2MD=OFF"
    "-DBUILD_MADDY=OFF"
  ];

  postInstall = ''
    mkdir -p $out/share/applications
    cp $src/net.mkiol.SpeechNote.desktop $out/share/applications/
    mkdir -p $out/share/icons/hicolor/scalable/apps
    cp $src/net.mkiol.SpeechNote.svg $out/share/icons/hicolor/scalable/apps/
  '';

  meta = with lib; {
    description = "Speech recognition and text-to-speech application";
    homepage = "https://github.com/mkiol/SpeechNote";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = [ ];
  };
})
