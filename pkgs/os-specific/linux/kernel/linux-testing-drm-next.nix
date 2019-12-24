{ stdenv, buildPackages, fetchgit, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

with stdenv.lib;

buildLinux (args // rec {
  version = "5.5-2019-12-20";
  modDirVersion = "5.5.0-rc2";

  src = fetchgit {
    url = "https://anongit.freedesktop.org/git/drm/drm.git";
    rev = "5f773e551a3b977013df24d570d486645f326672";
    sha256 = "0w3wqrz0ygll3ydvf0w0xh7xaqbjv15ybc79b3iw066c94ban35q";
  };

  extraMeta = {
    branch = "drm-next";
    hydraPlatforms = [];
  };
} // (args.argsOverride or {}))
