{ sources ? import ../../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
with pkgs;
let
  binaries = import ./binary-hashes.nix {};
in
  stdenvNoCC.mkDerivation rec {
    pname = "coco";
    version = "2014";
    srcs = builtins.map fetchurl (builtins.attrValues binaries);
    nativeBuildInputs  = [pkgs.unzip];
    unpackCmd = ''
      mkdir -p $out
      case "$curSrc" in
      *\.zip)
        unzip -q "$curSrc" -d $out/
        ;;
      *\.tgz)
        tar xfz "$curSrc" -C $out/
        ;;
      *)
        cp "$curSrc" $out/"$'' + ''{curSrc#*-}"
        ;;
      esac
      sourceRoot=`pwd`
    '';    
    dontFixup = true;
    dontInstall = true;
    meta = with lib; {
      description = "COCO-2014 datasets of Yolo format";
      longDescription = ''
        COCO-2014 datasets of Yolo format
        Original code is the shell script as follows.
        https://github.com/pjreddie/darknet/blob/master/scripts/get_coco_dataset.sh
      '';
      homepage = "";
      license = licenses.cc-by-40;
      platforms = platforms.all;
      maintainers = with maintainers; [ junjihashimoto ];
    };
  }
