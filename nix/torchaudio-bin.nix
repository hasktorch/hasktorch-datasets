{ pkgs }:
with pkgs;
let
  pyVerNoDot = builtins.replaceStrings [ "." ] [ "" ] python3.pythonVersion;
  srcs = import ./torchaudio-binary-hashes.nix version;
  unsupported = throw "Unsupported system";
  version = "0.8.1";
in
  with python3.pkgs; buildPythonPackage rec {
    pname = "torchaudio";
    inherit version;

    format = "wheel";

    src = fetchurl srcs."${stdenv.system}-${pyVerNoDot}" or unsupported;

    disabled = !(isPy37 || isPy38 || isPy39);

    checkInputs = [ pytest ];
    propagatedBuildInputs = [ pytorch-bin soundfile flake8 librosa scipy ];

    pythonImportsCheck = [ "torchaudio" ];

    postFixup = let
        rpath = lib.makeLibraryPath [ stdenv.cc.cc.lib ];
      in ''
        patchelf --set-rpath "${rpath}:${pytorch-bin}/${python3.sitePackages}/torch/lib:" \
          "$out/${python3.sitePackages}/torchaudio/_torchaudio.so"
      '';

    meta = {
      description = "Data manipulation and transformation for audio signal processing, powered by PyTorch";
      license = lib.licenses.bsd2;
      platforms = lib.platforms.linux;
      homepage = "https://github.com/pytorch/audio";
      maintainers = with lib.maintainers; [ tscholak ];
    };
  }