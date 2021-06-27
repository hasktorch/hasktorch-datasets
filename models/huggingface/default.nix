{ sources ? import ../../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
with pkgs;
let
  torchaudio-bin = import ../../nix/torchaudio-bin.nix { inherit pkgs; };
  myPython = python3.withPackages (ps: with ps;
    [ transformers
      datasets
      packaging
      sentencepiece
      pytorch-bin
      torchaudio-bin
      soundfile
    ]
  );
  mkDerivation = { pname, description, script, scriptArgs } : pkgs.stdenv.mkDerivation rec {
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
      python ${script} \
        --mode "${scriptArgs.mode}" \
        --model "${scriptArgs.model}" \
        ${lib.strings.optionalString (scriptArgs.mode == "trace") ''--input "${scriptArgs.input}"'' } \
        ${lib.strings.optionalString ((script == "gen_t5.py" || script == "gen_speech2text.py") && scriptArgs.mode == "trace") ''--decoder-input "${scriptArgs.decoder-input}"'' } \
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
    bert-base-uncased-trace = mkDerivation {
      pname = "bert-base-uncased-trace";
      description = "BERT-Base uncased for masked language modelling trace";
      script = "gen_bert.py";
      scriptArgs = {
        mode = "trace";
        model = "bert-base-uncased";
        input = "[CLS] Who was [MASK] Henson? [SEP] He was a puppeteer [SEP]";
        output = "bert-base-uncased-trace.pt";
      };
    };
    bert-base-uncased-state-dict = mkDerivation {
      pname = "bert-base-uncased-trace";
      description = "BERT-Base uncased for masked language modelling trace";
      script = "gen_bert.py";
      scriptArgs = {
        mode = "state-dict";
        model = "bert-base-uncased";
        output = "bert-base-uncased-state-dict.pt";
      };
    };
    t5-small-trace = mkDerivation {
      pname = "t5-small-trace";
      description = "T5-Small for conditional generation trace";
      script = "gen_t5.py";
      scriptArgs = {
        mode = "trace";
        model = "t5-small";
        input = "Studies have shown that owning a dog is good for you";
        decoder-input = "Studies show that";
        output = "t5-small-trace.pt";
      };
    };
    t5-small-state-dict = mkDerivation {
      pname = "t5-small-state-dict";
      description = "T5-Small for conditional generation state dictionary";
      script = "gen_t5.py";
      scriptArgs = {
        mode = "state-dict";
        model = "t5-small";
        output = "t5-small-state-dict.pt";
      };
    };
    t5-base-state-dict = mkDerivation {
      pname = "t5-base-state-dict";
      description = "T5-Base for conditional generation state dictionary";
      script = "gen_t5.py";
      scriptArgs = {
        mode = "state-dict";
        model = "t5-base";
        output = "t5-base-state-dict.pt";
      };
    };
    t5-large-state-dict = mkDerivation {
      pname = "t5-large-state-dict";
      description = "T5-Large for conditional generation state dictionary";
      script = "gen_t5.py";
      scriptArgs = {
        mode = "state-dict";
        model = "t5-large";
        output = "t5-large-state-dict.pt";
      };
    };
    t5-3b-state-dict = mkDerivation {
      pname = "t5-3b-state-dict";
      description = "T5-3B for conditional generation state dictionary";
      script = "gen_t5.py";
      scriptArgs = {
        mode = "state-dict";
        model = "t5-3b";
        output = "t5-3b-state-dict.pt";
      };
    };
    t5-11b-state-dict = mkDerivation {
      pname = "t5-11b-state-dict";
      description = "T5-11B for conditional generation state dictionary";
      script = "gen_t5.py";
      scriptArgs = {
        mode = "state-dict";
        model = "t5-11b";
        output = "t5-11b-state-dict.pt";
      };
    };
    speech2text-small-librispeech-asr-trace = mkDerivation {
      pname = "s2t-small-librispeech-asr-trace";
      description = "Speech2Text for conditional generation trace";
      script = "gen_speech2text.py";
      scriptArgs = {
        mode = "trace";
        model = "facebook/s2t-small-librispeech-asr";
        input = "patrickvonplaten/librispeech_asr_dummy";
        decoder-input = "Hello, my dog is cute";
        output = "speech2text-small-librispeech-asr-trace.pt";
      };
    };
    speech2text-small-librispeech-asr-state-dict = mkDerivation {
      pname = "s2t-small-librispeech-asr-trace";
      description = "Speech2Text for conditional generation state dictionary";
      script = "gen_speech2text.py";
      scriptArgs = {
        mode = "state-dict";
        model = "facebook/s2t-small-librispeech-asr";
        output = "speech2text-small-librispeech-asr-state-dict.pt";
      };
    };
  }