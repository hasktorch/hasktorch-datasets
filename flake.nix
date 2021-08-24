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
          datasets = {
            mnist = import datasets/mnist.nix {pkgs = pkgs-locked;};
            coco2014 = import datasets/coco/default.nix {pkgs = pkgs-locked;};
            bdd100k = import datasets/bdd100k/default.nix {pkgs = pkgs-locked;};
            bdd100k-mini = import datasets/bdd100k-mini/default.nix {pkgs = pkgs-locked;};
          };
          
          toPackages = {drvs, prefix}:
            let names = builtins.attrNames drvs;
                models = builtins.map (n: {
                  name = prefix + "-" + n;
                  value = drvs."${n}";
                }) names;
            in builtins.listToAttrs models;
      in {
        packages = (toPackages {drvs = datasets; prefix = "datasets";})
        // (toPackages {drvs = huggingface; prefix = "models-huggingface";})
        // (toPackages {drvs = torchvision; prefix = "models-torchvision";})
        // {models-yolov5 = yolov5;};
      }
    );
}
