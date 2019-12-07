{ stdenv, buildPackages, fetchgit, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

with stdenv.lib;

buildLinux (args // rec {
  version = "5.5-2019-12-06";
  modDirVersion = "5.4.0-rc7";

  src = fetchgit {
    url = "https://anongit.freedesktop.org/git/drm/drm.git";
    rev = "9c1867d730a6e1dc23dd633392d102860578c047";
    sha256 = "1r6pbpnw3x68rrqlvhmx85ppb2k4n2c9y7lgzg8xmxjf6yd7lajg";
  };

  extraMeta = {
    branch = "drm-next";
    hydraPlatforms = [];
  };
} // (args.argsOverride or {}))
