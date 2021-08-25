{ sources ? import ../../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
, dataset ? import ../bdd100k-mini/default.nix {}
}:
with pkgs;
let
  myPython = python3.withPackages (ps: with ps;
    [ imagesize
    ]
  );
in
  stdenvNoCC.mkDerivation rec {
    pname = dataset.pname + "-coco-annotation";
    version = "1.0";
    src = ./.;
    nativeBuildInputs  = [pkgs.unzip myPython];
    buildInputs  = [dataset];
    installPhase = ''
      mkdir -p $out
      pushd ${dataset.out}
      for i in * ; do
        ln -s ${dataset.out}/$i $out/$i
      done
      popd
      python yolo2coco.py ${dataset.out} $out
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
