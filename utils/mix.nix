{ datasetA
, pathA
, datasetB
, pathB
, rate
, name ? "xxx"
, sources ? import ../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
let
  lib = pkgs.lib;
  stdenvNoCC = pkgs.stdenvNoCC;
in
  stdenvNoCC.mkDerivation rec {
    pname = "mixed-datasets-" + name;
    version = "2021-06-09";
    nativeBuildInputs = [
    ];
    buildInputs = [
      datasetA
      datasetB
      pkgs.python
    ];
    src = ./.;
    buildPhase = ''
    '';
    installPhase = ''
      mkdir -p $out
      mkdir -p $out/train/{labels,images}
      mkdir -p $out/valid/{labels,images}
      NUM_DATASETA_TRAIN=`find -L ${datasetA.out}/${pathA} | grep train | grep images | grep "jpg\|png" | wc -l`
      NUM_DATASETB_TRAIN=`find -L ${datasetB.out}/${pathB} | grep train | grep images | grep "jpg\|png" | wc -l`
      NUM_DATASETA_VALID=`find -L ${datasetA.out}/${pathA} | grep valid | grep images | grep "jpg\|png" | wc -l`
      NUM_DATASETB_VALID=`find -L ${datasetB.out}/${pathB} | grep valid | grep images | grep "jpg\|png" | wc -l`
      #MIN (B*(R/(1-R)),A)
      #MIN (A*((1-R)/R),B)
      NUM_DA_T=`python cnt.py $NUM_DATASETA_TRAIN $NUM_DATASETB_TRAIN ${toString rate} A`
      NUM_DB_T=`python cnt.py $NUM_DATASETA_TRAIN $NUM_DATASETB_TRAIN ${toString rate} B`
      NUM_DA_V=`python cnt.py $NUM_DATASETA_VALID $NUM_DATASETB_VALID ${toString rate} A`
      NUM_DB_V=`python cnt.py $NUM_DATASETA_VALID $NUM_DATASETB_VALID ${toString rate} B`
      for t in train valid ; do
        pushd $out/$t/images
          for i in `find -L ${datasetA.out}/${pathA} | grep $t | grep images | grep "jpg\|png" | head -$NUM_DA_T` ; do
            ln -s $i          
          done
          for i in `find -L ${datasetB.out}/${pathB} | grep $t | grep images | grep "jpg\|png" | head -$NUM_DB_T` ; do
            ln -s $i          
          done
        popd
        pushd $out/$t/labels
          for i in `find -L ${datasetA.out}/${pathA} | grep $t | grep images | grep "jpg\|png" | head -$NUM_DA_V | sed -e 's/images/labels/' -e 's/jpg\|png/txt/'` ; do
            ln -s $i          
          done
          for i in `find -L ${datasetB.out}/${pathB} | grep $t | grep images | grep "jpg\|png" | head -$NUM_DB_V | sed -e 's/images/labels/' -e 's/jpg\|png/txt/'` ; do
            ln -s $i          
          done
        popd
      done
    '';
    phases = [];
    meta = with lib; {
      description = "mixed-dataset-" + name;
      longDescription = ''
      '';
      homepage = "";
      license = licenses.bsd3;
      platforms = platforms.all;
      maintainers = with maintainers; [ junjihashimoto ];
    };
  }
