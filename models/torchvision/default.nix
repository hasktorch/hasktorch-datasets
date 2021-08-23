{ sources ? import ../../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
with pkgs;
let
  myPython = python3.withPackages (ps: with ps;
    [ pytorch
      torchvision
    ]
  );
  genTorchScript = model_name :
    stdenvNoCC.mkDerivation rec {
      pname = model_name;
      version = "2021-06-09";
      src = ./.;
      nativeBuildInputs = [
        myPython
      ];
      buildPhase =
        ''
        python gen.py ${model_name} $TMPDIR
        '';
      installPhase =
        ''
        ls
        mkdir -p $out
        cp ${model_name}.pt $out
        '';
      meta = with lib; {
        description = "";
        longDescription = '''';
        homepage = "";
        license = licenses.cc-by-sa-30;
        platforms = platforms.all;
        maintainers =  [ "junjihashimoto" ];
      };
    };
in {
  alexnet = (genTorchScript "alexnet");
  resnet18 = (genTorchScript "resnet18");
}
  
