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
      echo "#datasets,mAP@.5" >> $out/mAP.csv
      echo -n "#datasets,AP@.5" >> $out/AP.csv
      echo ",person,rider,car,bus,truck,bike,motor,tl_green,tl_red,tl_yellow,tl_none,t_sign,train" >> $out/AP.csv
    '' + forEach (name: value: ''
      echo -n "${name}," >> $out/mAP.csv
      jq '.["mAP@.5"]' -r < ${value.out}/map_results.json >> $out/mAP.csv
      echo -n "${name}," >> $out/AP.csv
      jq '.["AP@.5"] | @csv' -r < ${value.out}/map_results.json >> $out/AP.csv
    '') datasets;
    phases = [ "installPhase" ];
  }
