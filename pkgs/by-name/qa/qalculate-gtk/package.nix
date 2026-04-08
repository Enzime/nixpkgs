{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  autoreconfHook,
  pkg-config,
  libqalculate,
  gtk3,
  gtk-mac-integration,
  curl,
  wrapGAppsHook3,
  desktopToDarwinBundle,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qalculate-gtk";
  version = "5.10.0";

  src = fetchFromGitHub {
    owner = "qalculate";
    repo = "qalculate-gtk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JZfolSRLRLtv529f25lEPYOlz+y+EdRqKA0Y5d1dK3s=";
  };

  patches = [
    # https://github.com/Qalculate/qalculate-gtk/pull/705
    (fetchpatch {
      name = "fix-platform-macos-conditional.patch";
      url = "https://github.com/Qalculate/qalculate-gtk/commit/f32ced1525c4cfc8e2c31b3f0d192371d1ffadc3.patch";
      hash = "sha256-v9T8wWvqlI9l6BUszf/575qmoFvh88Cdj/m2XqV8Q4k=";
    })
  ];

  hardeningDisable = [ "format" ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    wrapGAppsHook3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ desktopToDarwinBundle ];
  buildInputs = [
    libqalculate
    gtk3
    curl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ gtk-mac-integration ];
  enableParallelBuilding = true;

  meta = {
    description = "Ultimate desktop calculator";
    homepage = "http://qalculate.github.io";
    maintainers = with lib.maintainers; [
      doronbehar
      pentane
      aleksana
    ];
    license = lib.licenses.gpl2Plus;
    mainProgram = "qalculate-gtk";
    platforms = lib.platforms.all;
  };
})
