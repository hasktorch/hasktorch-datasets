{ sources ? import ../../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
with pkgs;
let
  binaries = import ./binary-hashes.nix {};
in
  stdenvNoCC.mkDerivation rec {
    pname = "bdd100k";
    version = "1.0";
    srcs = builtins.map fetchurl (builtins.attrValues binaries);
    nativeBuildInputs  = [pkgs.unzip];
    unpackCmd = ''
      if [ ! -d $out ] ; then
        mkdir -p $out
cat <<EOF > "$out/bdd100k.names"
person
rider
car
bus
truck
bike
motor
tl_green
tl_red
tl_yellow
tl_none
traffic sign
train
EOF
      fi
      if [ ! -L bdd100k ] ; then
        ln -s $out bdd100k
      fi
      case "$curSrc" in
      *bdd100k_[0-9]\.zip)
        unzip -q "$curSrc"
        ;;
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
      description = "BDD100k datasets of Yolo format";
      longDescription = ''
        BDD100K datasets of Yolo format
      '';
      homepage = "";
      license = licenses.bsd3;
      platforms = platforms.all;
      maintainers = with maintainers; [ junjihashimoto ];
    };
  }
