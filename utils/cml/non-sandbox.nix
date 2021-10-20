{pkgs
}:
with pkgs;
stdenv.mkDerivation {
  pname = "cml";
  version = "2018-11-16";
  src = fetchFromGitHub {
    owner = "iterative";
    repo = "cml";
    rev = "47b3ed6a4dfa847139f0da337ff40f7360a7b255";
    # nix-prefetch-url --unpack https://github.com/iterative/cml/archive/47b3ed6a4dfa847139f0da337ff40f7360a7b255.tar.gz
    sha256 = "0glvpk3b58ij11mxxza355mbzv14s1jfrksqw9cl020aav73g7wc";
  };
  nativeBuildInputs = [ nodePackages.npm nodejs python39 makeWrapper ];
  installPhase = ''
    ls > list
    export HOME=`pwd`
    mkdir -p $out/build/cml $out/bin
    cp -r `cat list` $out/build/cml
    touch .npmrc
    pushd $out/build/cml
    rm package-lock.json
    npm install
    sed -i -e 's|/usr/bin/env node|${nodejs}/bin/node|g' $out/build/cml/bin/cml.js
    makeWrapper $out/build/cml/bin/cml.js $out/bin/cml --set NODE_PATH $out/build/cml/node_modules
    popd
  '';
  #phases = [ "installPhase" ];
}

