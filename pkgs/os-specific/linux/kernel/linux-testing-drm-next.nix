{ stdenv, buildPackages, fetchgit, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

with stdenv.lib;

buildLinux (args // rec {
  version = "5.5-2019-12-18";
  modDirVersion = "5.5.0-rc2";

  src = fetchgit {
    url = "https://anongit.freedesktop.org/git/drm/drm.git";
    rev = "be452c4e8d1434a0095a9baa6523bb9772258d59";
    sha256 = "19x4k1nxasrrsqycaciq17n678hqv8xml0ba9gljfwarwyjmy2jv";
  };

  extraMeta = {
    branch = "drm-next";
    hydraPlatforms = [];
  };
} // (args.argsOverride or {}))
