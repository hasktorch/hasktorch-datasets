{ dataset
, sources ? import ../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
let
  lib = pkgs.lib;
  stdenvNoCC = pkgs.stdenvNoCC;
in
  stdenvNoCC.mkDerivation rec {
    pname = dataset.pname + "-mp4";
    version = "2021-07-08";
    nativeBuildInputs = [
      pkgs.ffmpeg
    ];
    buildInputs = [
      dataset
    ];
    src = ./.;
    buildPhase = ''
    '';
    installPhase = ''
      mkdir -p $out
      for i in `cd ${dataset.out}; find . -type d | grep -v '^.$'` ; do
        mkdir $out/$i
        pushd $out/$i
          if ls ${dataset.out}/$i | grep png ; then
            ffmpeg -r 30 -pattern_type glob -i "${dataset.out}/$i/*.png" -vcodec libx264 -pix_fmt yuv420p -r 60 out.mp4          
          elif ls ${dataset.out}/$i | grep jpg ; then
            ffmpeg -r 30 -pattern_type glob -i "${dataset.out}/$i/*.jpg" -vcodec libx264 -pix_fmt yuv420p -r 60 out.mp4          
          fi
        popd
      done
    '';
    phases = [];
    meta = with lib; {
      description = dataset.pname + "-mp4";
      longDescription = ''
      '';
      homepage = "";
      license = licenses.bsd3;
      platforms = platforms.all;
      maintainers = with maintainers; [ junjihashimoto ];
    };
  }
