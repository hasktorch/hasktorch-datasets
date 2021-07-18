{ sources ? import ../../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
, poetry2nix ? import sources.poetry2nix { inherit pkgs; poetry = pkgs.poetry; }
}:

with pkgs;

let

  mkDerivation = { pname, description, script, scriptArgs } : poetry2nix.mkPoetryApplication {
    inherit pname;
    version = "2021-06-27";
    projectDir = ./.;
    overrides = poetry2nix.overrides.withDefaults
      (self: super:
        {
          tokenizers = super.tokenizers.overridePythonAttrs (old: {
            nativeBuildInputs = old.nativeBuildInputs ++ [ rustc cargo ];
            buildInputs = old.buildInputs ++ [ self.setuptools-rust ];
          });
          torchaudio = super.torchaudio.overridePythonAttrs (old: {
            buildInputs = old.buildInputs ++ [ self.torch ];
            preConfigure =
              ''
                export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${self.torch}/${self.python.sitePackages}/torch/lib"
              '';
          });
        }
      );
    nativeBuildInputs = [
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
        ${lib.optionalString (scriptArgs.mode == "trace") ''--input "${scriptArgs.input}"'' } \
        ${lib.optionalString ((script == "gen_t5.py" || script == "gen_speech2text.py" || script == "gen_bart.py") && scriptArgs.mode == "trace") ''--decoder-input "${scriptArgs.decoder-input}"'' } \
        --output "${scriptArgs.output}" \
    '' + lib.optionalString (builtins.hasAttr "tokenizer-output" scriptArgs) ''
        --tokenizer-output "${scriptArgs.tokenizer-output}"
    '';
    installPhase = ''
      mkdir -p $out
      cp ${scriptArgs.output} $out
    '' + lib.optionalString (builtins.hasAttr "tokenizer-output" scriptArgs) ''
      cp ${scriptArgs.tokenizer-output} $out
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
        tokenizer-output = "bert-base-uncased-tokenizer.json";
      };
    };
    bert-base-uncased-state-dict = mkDerivation {
      pname = "bert-base-uncased-state-dict";
      description = "BERT-Base uncased for masked language modelling trace";
      script = "gen_bert.py";
      scriptArgs = {
        mode = "state-dict";
        model = "bert-base-uncased";
        output = "bert-base-uncased-state-dict.pt";
        tokenizer-output = "bert-base-uncased-tokenizer.json";
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
        tokenizer-output = "t5-small-tokenizer.json";
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
        tokenizer-output = "t5-small-tokenizer.json";
      };
    };
    byt5-small-state-dict = mkDerivation {
      pname = "byt5-small-state-dict";
      description = "ByT5-Small for conditional generation state dictionary";
      script = "gen_t5.py";
      scriptArgs = {
        mode = "state-dict";
        model = "google/byt5-small";
        output = "byt5-small-state-dict.pt";
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
        tokenizer-output = "t5-base-tokenizer.json";
      };
    };
    byt5-base-state-dict = mkDerivation {
      pname = "byt5-base-state-dict";
      description = "ByT5-Base for conditional generation state dictionary";
      script = "gen_t5.py";
      scriptArgs = {
        mode = "state-dict";
        model = "google/byt5-base";
        output = "byt5-base-state-dict.pt";
        tokenizer-output = "byt5-base-tokenizer.json";
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
        tokenizer-output = "t5-large-tokenizer.json";
      };
    };
    byt5-large-state-dict = mkDerivation {
      pname = "byt5-large-state-dict";
      description = "ByT5-Large for conditional generation state dictionary";
      script = "gen_t5.py";
      scriptArgs = {
        mode = "state-dict";
        model = "google/byt5-large";
        output = "byt5-large-state-dict.pt";
        tokenizer-output = "byt5-large-tokenizer.json";
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
        tokenizer-output = "t5-3b-tokenizer.json";
      };
    };
    byt5-xl-state-dict = mkDerivation {
      pname = "byt5-xl-state-dict";
      description = "ByT5-XL for conditional generation state dictionary";
      script = "gen_t5.py";
      scriptArgs = {
        mode = "state-dict";
        model = "google/byt5-xl";
        output = "byt5-xl-state-dict.pt";
        tokenizer-output = "byt5-xl-tokenizer.json";
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
        tokenizer-output = "t5-11b-tokenizer.json";
      };
    };
    byt5-xxl-state-dict = mkDerivation {
      pname = "byt5-xxl-state-dict";
      description = "ByT5-XXL for conditional generation state dictionary";
      script = "gen_t5.py";
      scriptArgs = {
        mode = "state-dict";
        model = "google/byt5-xxl";
        output = "byt5-xxl-state-dict.pt";
        tokenizer-output = "byt5-xxl-tokenizer.json";
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
        tokenizer-output = "speech2text-small-librispeech-asr-tokenizer.json";
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
        tokenizer-output = "speech2text-small-librispeech-asr-tokenizer.json";
      };
    };
    bart-base-state-dict = mkDerivation {
      pname = "bart-base-state-dict";
      description = "BART-Base for conditional generation state dictionary";
      script = "gen_bart.py";
      scriptArgs = {
        mode = "state-dict";
        model = "facebook/bart-base";
        output = "bart-base-state-dict.pt";
        tokenizer-output = "bart-base-tokenizer.json";
      };
    };
    bart-large-state-dict = mkDerivation {
      pname = "bart-large-state-dict";
      description = "BART-Large for conditional generation state dictionary";
      script = "gen_bart.py";
      scriptArgs = {
        mode = "state-dict";
        model = "facebook/bart-large";
        output = "bart-large-state-dict.pt";
        tokenizer-output = "bart-large-tokenizer.json";
      };
    };
  }
