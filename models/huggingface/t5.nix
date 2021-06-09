{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
with pkgs;
let
  cleanGit = (import sources.haskell-nix {}).pkgs.haskell-nix.haskellLib.cleanGit;
  myPython = python3.withPackages (ps: with ps;
    [ transformers
      packaging
      sentencepiece
    ]
  );
in
  pkgs.stdenv.mkDerivation rec {
    pname = "t5";
    version = "2021-06-09";
    nativeBuildInputs = [
      myPython
      curl
    ];
    buildInputs =  [];
    src = ./.;
    buildPhase = ''
      export CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
      #export REQUESTS_CA_BUNDLE=""
      export TRANSFORMERS_CACHE=$TMPDIR
      export XDG_CACHE_HOME=$TMPDIR
      python gen.py
    '';
    installPhase = ''
      mkdir -p $out
      cp t5.pt $out
    '';
    #phases = [ "installPhase" ];
    meta = with lib; {
      description = "t5";
      longDescription = ''
      '';
      homepage = "";
      license = licenses.bsd3;
      platforms = platforms.all;
      maintainers = with maintainers; [ junjihashimoto ];
    };
  }
