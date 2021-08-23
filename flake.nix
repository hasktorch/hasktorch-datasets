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
          
          toPackages = {drvs, prefix}:
            let names = builtins.attrNames drvs;
                models = builtins.map (n: {
                  name = prefix + "-" + n;
                  value = drvs."${n}";
                }) names;
            in builtins.listToAttrs models;
      in {
        packages = {
          datasets-mnist = import datasets/mnist.nix {pkgs = pkgs-locked;};
          datasets-coco2014 = import datasets/coco/default.nix {pkgs = pkgs-locked;};
          datasets-bdd100k = import datasets/bdd100k/default.nix {pkgs = pkgs-locked;};
          datasets-bdd100k-subset = import datasets/bdd100k-subset/default.nix {pkgs = pkgs-locked;};
        }
        // (toPackages {drvs = huggingface; prefix = "models-huggingface";})
        // (toPackages {drvs = torchvision; prefix = "models-torchvision";})
        // {models-yolov5 = yolov5;};
      }
    );
}
