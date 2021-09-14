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
in
  stdenv.mkDerivation rec {
    pname = "calc-map";
    version = "0.1";
    nativeBuildInputs = datasets_list ++ [jq];
    
    installPhase = ''
      mkdir -p $out
      for i in ${datasets_list_str}; do
        echo "---"$i"---" >> $out/report.md
        grep all $i/test.log >> $out/report.md 
        jq . < $i/map_results.json >> $out/report.md
      done
    '';
    phases = [ "installPhase" ];
  }
