{ pkgs
}:
with pkgs;
let
  srcs = {
    ja = fetchurl {
      url = "https://github.com/hasktorch/hasktorch-datasets/releases/download/common-voice/cv-corpus-7.0-2021-07-21-ja.tar.gz";
      sha256 = "0pzl80rpfmjly0xwqn4mvhyplxx3g4vghkgzip2paz1bvkq5y7ws";
    };
  };
in {
  ja = stdenvNoCC.mkDerivation rec {
    pname = "common-voice-corpus-7";
    version = "ja_29h_2021-07-21";
    installPhase = ''
      mkdir -p $out
      tar xf "${srcs.ja}" -C $out
      mv $out/cv-corpus-7.0-2021-07-21/ja/* $out/
      rmdir $out/cv-corpus-7.0-2021-07-21/ja
      rmdir $out/cv-corpus-7.0-2021-07-21
    '';
    phases = [ "installPhase" ];
    meta = with lib; {
      description = "";
      longDescription = ''
      '';
      homepage = "";
      license = licenses.cc0;
      platforms = platforms.all;
      maintainers = with maintainers; [ junjihashimoto ];
    };
  };
}
