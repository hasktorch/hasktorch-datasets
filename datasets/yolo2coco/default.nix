{ sources ? import ../../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
, bdd100k ? import ../bdd100k-mini/default.nix {}
}:
with pkgs;
let
  myPython = python3.withPackages (ps: with ps;
    [ imagesize
    ]
  );
in
  stdenvNoCC.mkDerivation rec {
    pname = bdd100k.pname + "-coco-annotation";
    version = "1.0";
    src = ./.;
    nativeBuildInputs  = [pkgs.unzip myPython];
    buildInputs  = [bdd100k];
    installPhase = ''
      mkdir -p $out
      pushd ${bdd100k.out}
      for i in * ; do
        ln -s ${bdd100k.out}/$i $out/$i
      done
      popd
      python yolo2coco.py ${bdd100k.out} $out
    '';    
    dontFixup = true;
    meta = with lib; {
      description = "Datasets with coco format";
      longDescription = ''
        Datasets with coco format
      '';
      homepage = "";
      license = licenses.bsd3;
      platforms = platforms.all;
      maintainers = with maintainers; [ junjihashimoto ];
    };
  }
