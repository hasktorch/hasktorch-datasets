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
        --model "${scriptArgs.model}"
        --output "${scriptArgs.output}"
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
    speech2text-small-librispeech-asr-trace = mkDerivation {
      pname = "s2t-small-librispeech-asr";
      description = "Speech2Text for inference";
      script = "inferences/speech2text.py";
      scriptArgs = {
        mode = "trace";
        model = "facebook/s2t-small-librispeech-asr";
        input = "patrickvonplaten/librispeech_asr_dummy";
        output = "speech2text-small-librispeech-asr-trace.pt";
      };
    };
  }
