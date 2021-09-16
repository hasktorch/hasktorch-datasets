{ pkgs
, datasets
}:
with pkgs;
let getValues = attrs:
      let names = builtins.attrNames attrs;
      in builtins.map (n: attrs."${n}") names;
    datasets_list = getValues datasets;
    datasets_list_str = builtins.concatStringsSep " " (
      builtins.map (n: builtins.toString(n.out)) datasets_list
    );
    headAttr = f: attrs:
      let name = builtins.head (builtins.attrNames attrs);
      in f name attrs."${name}";
    forEach = f: attrs: lib.concatStrings (lib.mapAttrsToList f attrs);
in
  stdenv.mkDerivation rec {
    pname = "calc-map";
    version = "0.1";
    nativeBuildInputs = datasets_list ++ [jq];
    installPhase = ''
      mkdir -p $out
      echo "#datasets,images,mAP@.5" >> $out/mAP.csv
    '' + headAttr (name: value: ''
      echo -n "datasets," >> $out/AP.csv
      grep names: ${value.out}/dataset.test.yaml  | sed -e "s/'/\"/g" -e 's/names://g' | jq "@csv" -r >> $out/AP.csv
    '') datasets
    + forEach (name: value: ''
      echo -n "${name}," >> $out/mAP.csv
      grep "  all   " ${value.out}/test.log  | awk '{printf $2","}' >> $out/mAP.csv
      jq '.["mAP@.5"]' -r < ${value.out}/map_results.json >> $out/mAP.csv
      echo -n "${name}," >> $out/AP.csv
      jq '.["AP@.5"] | @csv' -r < ${value.out}/map_results.json >> $out/AP.csv
    '') datasets;
    phases = [ "installPhase" ];
  }
