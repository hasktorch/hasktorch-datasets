{ sources ? import ../../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
, poetry2nix ? import sources.poetry2nix { inherit pkgs; poetry = pkgs.poetry; }
}:

with pkgs;

let
  env = poetry2nix.mkPoetryEnv {
    python = python3;
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
  };
in
env