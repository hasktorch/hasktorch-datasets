{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
with pkgs;
let
  cleanGit = (import sources.haskell-nix {}).pkgs.haskell-nix.haskellLib.cleanGit;
  myPython = python3.withPackages (ps: with ps;
    [ cython
      matplotlib
      numpy
      opencv4
      pillow
      pytorch
      pyyaml
      scipy
      tensorflow-tensorboard
      torchvision
    ]
  );
in
  pkgs.stdenv.mkDerivation rec {
    pname = "yolov5s";
    version = "2021-06-09";
    nativeBuildInputs = [
      myPython
    ];
    buildInputs =  [];
    src = cleanGit {
      name = "root";
      src = ./.;
    };
    buildPhase = ''
      python models/export.py --weights yolov5s.pt --img 640 --batch 1
    '';
    installPhase = ''
      mkdir -p $out
      cp yolov5s.pt $out
    '';
    #phases = [ "installPhase" ];
    meta = with lib; {
      description = "yolov5";
      longDescription = ''
      '';
      homepage = "";
      license = licenses.bsd3;
      platforms = platforms.all;
      maintainers = with maintainers; [ junjihashimoto ];
    };
  }
