{ sources ? import ../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
with pkgs;
let
  srcs = {
    train-images = fetchurl {
      url = "https://pjreddie.com/media/files/train2014.zip";
      sha256 = "";
    };
    train-labels = fetchurl {
      url = "";
      sha256 = "";
    };
    test-images = fetchurl {
      url = "https://pjreddie.com/media/files/val2014.zip";
      sha256 = "1rn4vfigaxn2ms24bf4jwzzflgp3hvz0gksvb8j7j70w19xjqhld";
    };
    test-labels = fetchurl {
      url = "";
      sha256 = "";
    };
  };
in
  stdenvNoCC.mkDerivation rec {
    pname = "coco";
    version = "pjreddie-2014";
    installPhase = ''
      mkdir -p $out
      ln -s "${srcs.train-images}" "$out/${srcs.train-images.name}"
      ln -s "${srcs.train-labels}" "$out/${srcs.train-labels.name}"
      ln -s "${srcs.test-images}" "$out/${srcs.test-images.name}"
      ln -s "${srcs.test-labels}" "$out/${srcs.test-labels.name}"
    '';
    phases = [ "installPhase" ];
    meta = with lib; {
      description = "";
      longDescription = ''
      '';
      homepage = "https://github.com/pjreddie/darknet/blob/master/scripts/get_coco_dataset.sh";
      license = licenses.bsd3;
      platforms = platforms.all;
      maintainers = with maintainers; [ junjihashimoto ];
    };
  }
