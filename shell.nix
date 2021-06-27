{ sources ? import ./nix/sources.nix
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
in
  pkgs.mkShell {
    buildInputs = [
      myPython
    ];
    shellHook = ''
      # Tells pip to put packages into $PIP_PREFIX instead of the usual locations.
      # See https://pip.pypa.io/en/stable/user_guide/#environment-variables.
      export PIP_PREFIX=$(pwd)/_build/pip_packages
      export PYTHONPATH="$PIP_PREFIX/${pkgs.python3.sitePackages}:$PYTHONPATH"
      export PATH="$PIP_PREFIX/bin:$PATH"
      unset SOURCE_DATE_EPOCH
    '';
  }