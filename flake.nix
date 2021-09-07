{
  description = "Datasets";
  
  nixConfig = {
    # This is for getting pretrained models.
    useSandbox = false;
  };
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-locked.url = "github:nixos/nixpkgs?rev=12e7af1cfb3ab5bbbbd1d213a0b17c11ce9d3f2f";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, nixpkgs-locked, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          pkgs-locked = nixpkgs-locked.legacyPackages.${system};

          huggingface = import ./models/huggingface/default.nix {inherit pkgs;};
          torchvision = import ./models/torchvision/default.nix {inherit pkgs;};
          yolov5 = import ./models/yolov5/default.nix {inherit pkgs;};
          datasets = rec{
            mnist = import datasets/mnist.nix {pkgs = pkgs-locked;};
            coco2014 = import datasets/coco/default.nix {pkgs = pkgs-locked;};
            bdd100k = import datasets/bdd100k/default.nix {pkgs = pkgs-locked;};
            bdd100k-coco = import datasets/yolo2coco/default.nix {pkgs = pkgs-locked; dataset = bdd100k; };
            bdd100k-mini = import datasets/bdd100k-mini/default.nix {pkgs = pkgs-locked;};
            bdd100k-mini-coco = import datasets/yolo2coco/default.nix {pkgs = pkgs-locked; dataset = bdd100k-mini; };
            bdd100k-subset = import datasets/bdd100k-subset/subsets.nix {pkgs = pkgs-locked;};
          };
          
          toPackages = {drvs, prefix}:
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
      in {
        packages = (toPackages {drvs = datasets; prefix = "datasets";})
        // (toPackages {drvs = huggingface; prefix = "models-huggingface";})
        // (toPackages {drvs = torchvision; prefix = "models-torchvision";})
        // {models-yolov5 = yolov5;};
      }
    );
}
