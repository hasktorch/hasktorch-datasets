{ dataset
, from ? "jpg"
, to ? "png"
, sources ? import ../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
let
  lib = pkgs.lib;
  stdenvNoCC = pkgs.stdenvNoCC;
in
  stdenvNoCC.mkDerivation rec {
    pname = dataset.pname + "-" + from + "-to-" + to;
    version = "2021-07-08";
    nativeBuildInputs = [
      pkgs.imagemagick
    ];
    buildInputs = [
      dataset
    ];
    src = ./.;
    buildPhase = ''
    '';
    installPhase = ''
      mkdir -p $out
      for i in `cd ${dataset.out}; find . -type d | grep -v '^.$'` ; do
        mkdir $out/$i
      done
      for i in `cd ${dataset.out}; find . -type f,l | grep ${from}$` ; do
        convert ${dataset.out}/$i $out/${ "$" + "{i%" + from + "}"}${to}
      done
      for i in `cd ${dataset.out}; find . -type f,l | grep -v ${from}$` ; do
        ln -s ${dataset.out}/$i $out/$i
      done
    '';
    phases = [];
    meta = with lib; {
      description = dataset.pname + "-" from + "-to-" + to;
      longDescription = ''
      '';
      homepage = "";
      license = licenses.bsd3;
      platforms = platforms.all;
      maintainers = with maintainers; [ junjihashimoto ];
    };
  }
