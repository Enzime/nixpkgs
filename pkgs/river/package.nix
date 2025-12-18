{
  lib,
  stdenv,
  callPackage,
  fetchFromGitea,
  libGL,
  libX11,
  libevdev,
  libinput,
  libxkbcommon,
  pixman,
  pkg-config,
  scdoc,
  udev,
  versionCheckHook,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots_0_19,
  xwayland,
  zig_0_15,
  withManpages ? true,
  xwaylandSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "river";
  version = "0.3.12";

  outputs = [ "out" ] ++ lib.optionals withManpages [ "man" ];

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "river";
    repo = "river";
    tag = "v${finalAttrs.version}";
    hash = lib.fakeHash;
  };

  deps = callPackage ./build.zig.zon.nix { };

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
    xwayland
    zig_0_15.hook
  ] ++ lib.optional withManpages scdoc;

  buildInputs = [
    libGL
    libevdev
    libinput
    libxkbcommon
    pixman
    udev
    wayland
    wayland-protocols
    wlroots_0_19
  ] ++ lib.optional xwaylandSupport libX11;

  dontConfigure = true;

  zigBuildFlags =
    [
      "--system"
      "${finalAttrs.deps}"
    ]
    ++ lib.optional withManpages "-Dman-pages"
    ++ lib.optional xwaylandSupport "-Dxwayland";

  postInstall = ''
    install contrib/river.desktop -Dt $out/share/wayland-sessions
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-version";

  passthru = {
    providedSessions = [ "river" ];
  };

  meta = {
    homepage = "https://codeberg.org/river/river";
    description = "Dynamic tiling Wayland compositor";
    longDescription = ''
      River is a dynamic tiling Wayland compositor with flexible runtime
      configuration.
    '';
    changelog = "https://codeberg.org/river/river/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "river";
    platforms = lib.platforms.linux;
  };
})
