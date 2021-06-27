{ sources ? import ../../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
with pkgs;
let
  myPython = python3.withPackages (ps: with ps;
    [ transformers
      packaging
      sentencepiece
      pytorch
    ]
  );
  mkT5Derivation = { pname, description, scriptArgs } : pkgs.stdenv.mkDerivation rec {
    inherit pname;
    version = "2021-06-27";
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
      python gen_t5.py \
        --mode "${scriptArgs.mode}" \
        --model "${scriptArgs.model}" \
        ${lib.strings.optionalString (scriptArgs.mode == "trace") ''--input "${scriptArgs.input}"'' } \
        ${lib.strings.optionalString (scriptArgs.mode == "trace") ''--decoder-input "${scriptArgs.decoder-input}"'' } \
        --output "${scriptArgs.output}"
    '';
    installPhase = ''
      mkdir -p $out
      cp ${scriptArgs.output} $out
    '';
    meta = with lib; {
      inherit description;
      longDescription = ''
      '';
      homepage = "";
      license = licenses.bsd3;
      platforms = platforms.all;
      maintainers = with maintainers; [ junjihashimoto tscholak ];
    };
  };
in
  { 
    t5-small-trace = mkT5Derivation {
      pname = "t5-small-trace";
      description = "T5-Small for conditional generation trace";
      scriptArgs = {
        mode = "trace";
        model = "t5-small";
        input = "Studies have shown that owning a dog is good for you";
        decoder-input = "Studies show that";
        output = "t5-small-trace.pt";
      };
    };
    t5-small-state-dict = mkT5Derivation {
      pname = "t5-small-state-dict";
      description = "T5-Small for conditional generation state dictionary";
      scriptArgs = {
        mode = "state-dict";
        model = "t5-small";
        output = "t5-small-state-dict.pt";
      };
    };
    t5-base-state-dict = mkT5Derivation {
      pname = "t5-base-state-dict";
      description = "T5-Base for conditional generation state dictionary";
      scriptArgs = {
        mode = "state-dict";
        model = "t5-base";
        output = "t5-base-state-dict.pt";
      };
    };
    t5-large-state-dict = mkT5Derivation {
      pname = "t5-large-state-dict";
      description = "T5-Large for conditional generation state dictionary";
      scriptArgs = {
        mode = "state-dict";
        model = "t5-large";
        output = "t5-large-state-dict.pt";
      };
    };
    t5-3b-state-dict = mkT5Derivation {
      pname = "t5-3b-state-dict";
      description = "T5-3B for conditional generation state dictionary";
      scriptArgs = {
        mode = "state-dict";
        model = "t5-3b";
        output = "t5-3b-state-dict.pt";
      };
    };
    t5-11b-state-dict = mkT5Derivation {
      pname = "t5-11b-state-dict";
      description = "T5-11B for conditional generation state dictionary";
      scriptArgs = {
        mode = "state-dict";
        model = "t5-11b";
        output = "t5-11b-state-dict.pt";
      };
    };
  }