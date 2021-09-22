{ sources ? import ../../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
with pkgs;
let
  binaries = import ./binary-hashes.nix {};
in
args@{...}:
  stdenvNoCC.mkDerivation (rec {
      pname = "bdd100k-mini";
      version = "1.0";
      srcs =  builtins.map fetchurl (builtins.attrValues binaries);
      nativeBuildInputs  = [pkgs.unzip];
      unpackCmd = ''
        mkdir -p $out
        case "$curSrc" in
        *bdd100k-subset\.zip)
          ln -s $out few-bdd100k
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
        description = "The subset of BDD100k datasets of Yolo format";
        longDescription = ''
          The subset of BDD100K datasets of Yolo format
        '';
        homepage = "";
        license = licenses.bsd3;
        platforms = platforms.all;
        maintainers = with maintainers; [ junjihashimoto ];
      };
  } // args)
