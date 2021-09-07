{ sources ? import ../../nix/sources.nix
, pkgs ? import sources.nixpkgs {}
, bdd100k ? import ../bdd100k/default.nix {}
, name ? "subset"
}:
with pkgs;
let
  func = name: cond: import ./default.nix {
    inherit pkgs;
    inherit bdd100k;
    inherit name;
    filter = cond;
  };
  conditions = {
    weather = [
      "clear"
      "foggy"
      "overcast"
      "partly cloudy"
      "rainy"
      "snowy"
    ];
    scene = [
      "city street"
      "gas stations"
      "highway"
      "parking lot"
      "residential"
      "tunnel"
    ];
    timeofday = [
      "dawn/dusk"
      "daytime"
      "night"
    ];
  };
  conditions_map =
    builtins.concatLists (
      builtins.map (n:
        map (m:
          rec {
            name = "${n}-${m}";
            value = func name " ${n} == '${m}' " ;
          }
        ) conditions."${n}"
      ) (builtins.attrNames conditions)
    );
in builtins.listToAttrs conditions_map
