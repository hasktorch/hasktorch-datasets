{ pkgs
}:
{
  src2drv = binaries:
    pkgs.stdenvNoCC.mkDerivation {
      pname = "src2drv";
      version = "1.0";
      srcs = builtins.map builtins.fetchurl (builtins.attrValues binaries);
      nativeBuildInputs  = [pkgs.unzip];
      unpackCmd = ''
        if [ ! -d $out ] ; then
          mkdir -p $out
        fi
        case "$curSrc" in
        *\.zip)
          unzip -q "$curSrc" -d $out/
          ;;
        *\.tgz)
          tar xfz "$curSrc" -C $out/
          ;;
        *)
          cp "$curSrc" $out/"$'' + ''{curSrc#*-}"
          ;;
        esac
        sourceRoot=`pwd`
      '';    
      dontFixup = true;
      dontInstall = true;
    };

  mapDatasets = prefix: datasets: f: builtins.listToAttrs (
    builtins.map (n:
      {
        name = prefix + n;
        value = f datasets."${n}";
      }
    ) (builtins.attrNames datasets)
  );

  excludeFiles = exclude_lists: src:
    builtins.filterSource
      (path: type: ! (builtins.any
        (pattern:
          builtins.isList (builtins.match pattern (baseNameOf path))
        )
        ([".*\.nix$"] ++ exclude_lists)
      ))
      src;

  flattenDerivations = {drvs, prefix}:
    let models = {drvs, prefix}:
          with builtins;
          let names = attrNames drvs;
              n = head names;
          in
            concatLists (
              map (n:
                if typeOf (drvs."${n}") == "set" && hasAttr "drvPath" drvs."${n}"
                then
                  [{
                    name = prefix + "-" + n;
                    value = drvs."${n}";
                  }] 
                else
                  models {
                    drvs=drvs."${n}";
                    prefix=prefix + "-" + n;
                  }
              ) names
            );
        m = models {inherit drvs; inherit prefix;};
    in builtins.listToAttrs m;

  iota = n: start:
    if n == 0
    then []
    else [start] ++ iota (n - 1) (start+1);
  
  trainingLoopDerivation = {
    , epochs
    , trainingDerivation
    , scriptArgs'
    }: 
    in builtins.foldl'
      (prev: epoch:
        trainingDerivation {
          pretrained = prev;
          scriptArgs = scriptArgs' epoch;
        }
      ) (trainingDerivation {
        scriptArgs = scriptArgs' 1;
      }
      ) (iota epochs 2);
}
