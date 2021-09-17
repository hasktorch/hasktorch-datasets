{ pkgs
, yolov5s_bdd100k
}:
let
  lib = pkgs.lib;
  myPython = pkgs.python3.withPackages (ps: with ps;
    [ cython
      matplotlib
      numpy
      opencv4
      pillow
      pytorch-bin
      torchvision-bin
      pyyaml
      scipy
      tensorflow-tensorboard
      pandas
      tqdm
      seaborn
    ]
  );
  detect = { name ? "bdd100k"
           , dataset
           , weights ? "runs/exp1_yolov5s_bdd/weights/best_yolov5s_bdd.pt"
           }:
    pkgs.stdenv.mkDerivation rec {
    pname = "detect";
    version = "1";
    nativeBuildInputs = [
      myPython
      pkgs.curl
    ];
    buildInputs =  [];
    src = yolov5s_bdd100k;
    buildPhase = ''
      ls /run | grep open
      ls /dev | grep nvidia
      export PIP_PREFIX=$(pwd)/_build/pip_packages
      export PYTHONPATH="$PIP_PREFIX/${pkgs.python3.sitePackages}:$PYTHONPATH"
      export PATH="$PIP_PREFIX/bin:$PATH"
      unset SOURCE_DATE_EPOCH
      export PARAMS=${weights}
      mkdir .cache
      mkdir out
      cmdWrapper () {
        echo ----
        echo $@
        pwd
        date
        echo ----
        $@
      }
      for i in `cd ${dataset.out}; find . -type d | grep -v '^.$'` ; do
        mkdir out/$i
      done
      for i in `cd ${dataset.out}; find . -type d | grep -v '^.$'` ; do
        if ls ${dataset.out}/$i | grep "jpg\|png\|bmp" > /dev/null; then
          cmdWrapper python detect.py  \
           --weights $PARAMS \
           --source ${dataset.out}/$i \
           --output out/$i \
           --save-txt \
            2>&1 | tee detect.log
          TO=`echo out/$i | sed -e 's/images/labels/g'`
          if [ ! -d $TO ] ; then
            mkdir -p $TO
          fi
          mv out/$i/*.txt $TO
        fi
      done
    '';
    installPhase = ''
      mkdir -p $out/
      cp *.log $out/
      cp -r out/* $out/
    '';
    #phases = [ "installPhase" ];
    meta = with lib; {
      description = "yolov5s-detect";
      longDescription = ''
      '';
      homepage = "";
      license = licenses.bsd3;
      platforms = platforms.all;
      maintainers = with maintainers; [ junjihashimoto ];
    };
  };
  train = { name ? "bdd100k"
           , dataset
           , epochs ? "300"
           , batch ? "32"
           , device ? "0"
           , num-workers ? "0"
           }:
    pkgs.stdenv.mkDerivation rec {
    pname = "train";
    version = "1";
    nativeBuildInputs = [
      myPython
      pkgs.curl
      pkgs.breakpointHook
      pkgs.strace
    ];
    buildInputs =  [];
    src = yolov5s_bdd100k;
    buildPhase = ''
      ls -l /run/opengl-driver/lib
      ls -l /dev | grep nvidia
      export PIP_PREFIX=$(pwd)/_build/pip_packages
      export PYTHONPATH="$PIP_PREFIX/${pkgs.python3.sitePackages}:$PYTHONPATH"
      export PATH="$PIP_PREFIX/bin:$PATH"
      unset SOURCE_DATE_EPOCH
      export DATASET=${dataset.out}/images/trains
      export MPLCONFIGDIR=$TMPDIR
      mkdir .cache
      cmdWrapper () {
        echo ----
        echo $@ > cmd.sh
        export > env.sh
        echo $@
        pwd
        date
        echo ----
#        exit 1
        $@
      }
cat << EOF > dataset.train.yaml
train: $DATASET
val: `echo $DATASET | sed -e 's/trains/valids/g' -e 's/train/valid/g'`
test: `echo $DATASET | sed -e 's/trains/tests/g' -e 's/train/test/g'`

nc: 13
names: ['person','rider','car','bus','truck','bike','motor','tl_green','tl_red','tl_yellow','tl_none','t_sign','train']
EOF
      rm -rf runs/exp*
      cat dataset.train.yaml
      cmdWrapper python train.py --img 640 --batch ${batch} --epochs ${epochs} \
             --data dataset.train.yaml --cfg ./models/custom_yolov5s.yaml \
             --device ${device} \
             --num-workers ${num-workers} \
             --name ${name} 2>&1 | tee train.log
    '';
    installPhase = ''
      echo intall
      mkdir -p $out
      cp -r {.,$out}/runs
      cp *.log $out/
      cp *.json $out/
      cp *.yaml $out/
    '';
    #phases = [ "installPhase" ];
    meta = with lib; {
      description = "yolov5s-detect";
      longDescription = ''
      '';
      homepage = "";
      license = licenses.bsd3;
      platforms = platforms.all;
      maintainers = with maintainers; [ junjihashimoto ];
    };
  };
  fine-tuning = { name ? "bdd100k"
                , dataset
                , epochs ? "10"
                , batch ? "32"
                , device ? "0"
                , num-workers ? "0"
                , weights ? ""
                }:
    pkgs.stdenv.mkDerivation rec {
    pname = "fine-tuning";
    version = "1";
    nativeBuildInputs = [
      myPython
      pkgs.curl
      pkgs.breakpointHook
      pkgs.strace
    ];
    buildInputs =  [];
    src = yolov5s_bdd100k;
    buildPhase = ''
      ls -l /run/opengl-driver/lib
      ls -l /dev | grep nvidia
      export PIP_PREFIX=$(pwd)/_build/pip_packages
      export PYTHONPATH="$PIP_PREFIX/${pkgs.python3.sitePackages}:$PYTHONPATH"
      export PATH="$PIP_PREFIX/bin:$PATH"
      unset SOURCE_DATE_EPOCH
      export DATASET=${dataset.out}/images/trains
      export MPLCONFIGDIR=$TMPDIR
      mkdir .cache
      cmdWrapper () {
        echo ----
        echo $@ > cmd.sh
        export > env.sh
        echo $@
        pwd
        date
        echo ----
#        exit 1
        $@
      }
cat << EOF > dataset.train.yaml
train: $DATASET
val: `echo $DATASET | sed -e 's/trains/valids/g' -e 's/train/valid/g'`
test: `echo $DATASET | sed -e 's/trains/tests/g' -e 's/train/test/g'`

nc: 13
names: ['person','rider','car','bus','truck','bike','motor','tl_green','tl_red','tl_yellow','tl_none','t_sign','train']
EOF
      mv runs/exp1_yolov5s_bdd/weights/best_yolov5s_bdd.pt .
      if [ -z "$weights" ] ; then
        WEIGHTS=best_yolov5s_bdd.pt
      else
        WEIGHTS=${weights}
      fi
      rm -rf runs/exp*
      cat dataset.train.yaml
      cmdWrapper python train.py --img 640 --batch ${batch} --epochs ${epochs} \
             --data dataset.train.yaml --cfg ./models/custom_yolov5s.yaml \
             --device ${device} \
             --num-workers ${num-workers} \
             --weights $WEIGHTS \
             --name ${name} 2>&1 | tee train.log
    '';
    installPhase = ''
      echo intall
      mkdir -p $out
      cp -r {.,$out}/runs
      cp *.log $out/
      cp *.json $out/
      cp *.yaml $out/
    '';
    #phases = [ "installPhase" ];
    meta = with lib; {
      description = "yolov5s-fine-tuning";
      longDescription = ''
      '';
      homepage = "";
      license = licenses.bsd3;
      platforms = platforms.all;
      maintainers = with maintainers; [ junjihashimoto ];
    };
  };
  test = { name ? "bdd100k"
         , dataset
         , weights ? "runs/exp1_yolov5s_bdd/weights/best_yolov5s_bdd.pt"
         , batch ? "32"
         , device ? "0"
         , num-workers ? "0"
         , useDefaultWeights ? false
         }:
    pkgs.stdenv.mkDerivation rec {
    pname = "test";
    version = "1";
    nativeBuildInputs = [
      myPython
      pkgs.curl
    ];
    buildInputs =  [];
    src = yolov5s_bdd100k;
    patches = [./patches/bdd100k.patch];
    buildPhase =
      let removeDefaultWeights = if useDefaultWeights then "" else "rm -rf runs/exp*";
      in
      ''
      ls -l /run/opengl-driver/lib
      #ls -l /dev | grep nvidia
      export PIP_PREFIX=$(pwd)/_build/pip_packages
      export PYTHONPATH="$PIP_PREFIX/${pkgs.python3.sitePackages}:$PYTHONPATH"
      export PATH="$PIP_PREFIX/bin:$PATH"
      unset SOURCE_DATE_EPOCH
      export DATASET=${dataset.out}/images/trains
      export MPLCONFIGDIR=$TMPDIR
      mkdir .cache
      cmdWrapper () {
        echo ----
        echo $@
        pwd
        date
        echo ----
        $@
      }
cat << EOF > dataset.test.yaml
train: $DATASET
val: `echo $DATASET | sed -e 's/trains/valids/g' -e 's/train/valid/g'`
test: `echo $DATASET | sed -e 's/trains/tests/g' -e 's/train/test/g'`

nc: 13
names: ['person','rider','car','bus','truck','bike','motor','tl_green','tl_red','tl_yellow','tl_none','t_sign','train']
EOF
      ${removeDefaultWeights}
      cat dataset.test.yaml
      cmdWrapper python test.py --img 640 --batch ${batch} \
             --data dataset.test.yaml \
             --device ${device} \
             --weights ${weights} 2>&1 | tee test.log
    '';
    installPhase = ''
      echo intall
      mkdir -p $out
      cp -r {.,$out}/runs
      cp *.jpg $out/
      cp *.log $out/
      cp *.json $out/
      cp *.yaml $out/
    '';
    #phases = [ "installPhase" ];
    meta = with lib; {
      description = "yolov5s-test";
      longDescription = ''
      '';
      homepage = "";
      license = licenses.bsd3;
      platforms = platforms.all;
      maintainers = with maintainers; [ junjihashimoto ];
    };
  };
in {
  inherit detect;
  inherit train;
  inherit fine-tuning;
  inherit test;
}
