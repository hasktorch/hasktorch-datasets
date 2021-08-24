{ sources ? import ../../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
, bdd100k ? import ../bdd100k/default.nix {}
, name ? "subset"
, filter ? " weather == 'rainy' "
}:
with pkgs;
let
  myPython = python3.withPackages (ps: with ps;
    [ ijson
    ]
  );
in
  stdenvNoCC.mkDerivation rec {
    pname = "bdd100k-" + name;
    version = "1.0";
    src = ./.;
    nativeBuildInputs  = [pkgs.unzip myPython];
    buildInputs  = [bdd100k];
    installPhase = ''
      sed -i -e "s/__filter__/${filter}/g" filter.py
      python filter.py ${bdd100k.out} $out
    '';    
    dontFixup = true;
    meta = with lib; {
      description = "The subset of BDD100k datasets of Yolo format";
      longDescription = ''
        The subset of BDD100K datasets of Yolo format
      '';
      homepage = "";
      license = licenses.bsd3;
      platforms = platforms.all;
      maintainers = with maintainers; [ junjihashimoto ];
    };
  }
