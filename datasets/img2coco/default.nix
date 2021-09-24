{ sources ? import ../../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
, dataset
, datasetForLabels
, nixflow ? import ../../nix/nixflow.nix {inherit pkgs;}
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
    src = (nixflow.excludeFiles [] ./.);
    nativeBuildInputs  = [pkgs.unzip myPython];
    buildInputs  = [dataset datasetForLabels];
    installPhase = ''
      set -x
      mkdir -p $out/images/{trains,valids}
      pushd ${dataset.out}
      for i in *.jpg *.png ; do
        ln -s ${dataset.out}/$i $out/images/valids/$i
      done
      popd
      if [ ! -d  $out/annotations ] ; then
        mkdir -p $out/annotations
      fi
      python img2coco.py $out $out ${datasetForLabels.out}/*.names
      
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
