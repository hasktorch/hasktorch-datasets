{ sources ? import ../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
with pkgs;
{
  fetchlocal = {path, sha256}: pkgs.runCommandNoCC (baseNameOf path) ({
      nativeBuildInputs = [
        pkgs.unzip
      ];
      outputHashAlgo = "sha256";
      outputHash = sha256;
      outputHashMode = "recursive";
      preferLocalBuild = true;
  } )
    ''
    unzip -q ${path} -d $out
    if [ `ls $out | wc -l` = 1] ; then
      subdir=`ls $out`
      mv $out/$subdir/* $out
      rmdir $out/$subdir
    fi
    '';
  cleanGit = (import sources.haskell-nix {}).pkgs.haskell-nix.haskellLib.cleanGit;
}
