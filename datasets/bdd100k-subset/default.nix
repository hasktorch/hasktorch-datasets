{ sources ? import ../../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
, bdd100k ? import ../bdd100k/default.nix {}
, name ? "subset"
, filter ? "[ $weather = rainy ]"
}:
with pkgs;
  stdenvNoCC.mkDerivation rec {
    pname = "bdd100k-" + name;
    version = "1.0";
    #src = false;
    nativeBuildInputs  = [pkgs.unzip pkgs.perl];
    buildInputs  = [bdd100k];
    unpackPhase = "true";
    installPhase = ''
      if [ ! -d $out ] ; then
        mkdir -p $out/{images,labels}/{trains,valids}
      fi
      ln -s ${bdd100k.out}/bdd100k.names $out/bdd100k.names
      for f in ${bdd100k.out}/bdd100k_labels_images_*.json ; do
        case "$f" in
        *train*)
          dir=trains
          ;;
        *val*)
          dir=valids
          ;;
        esac
        for i in `grep 'name\|weather\|scene\|timeofday' $f | sed -e 's/  \+//g' -e 's/"//g' -e 's/name: //g' -e 's/.jpg//g' -e 's/: /:/g' -e 's/ /-/g'| perl -pe 's/,\n/,/g'` ; do
          filename=$(echo $i | cut -d "," -f 1).jpg
          weather=$(echo $i | cut -d "," -f 2 | sed -e 's/weather://g')
          scene=$(echo $i | cut -d "," -f 3 | sed -e 's/scene://g')
          timeofday=$(echo $i | cut -d "," -f 4 | sed -e 's/timeofday://g')
          #echo "--debug--"
          #echo ${filter}
          if ${filter} ; then
            ln -s ${bdd100k.out}/images/$dir/$filename $out/images/$dir/$filename
            ln -s ${bdd100k.out}/labels/$dir/$filename $out/labels/$dir/$filename
          fi
        done
      done
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
