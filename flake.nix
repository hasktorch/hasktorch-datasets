{
  description = "Datasets";
  
  nixConfig = {
    # This is for getting pretrained models.
    # sandbox = false;
  };
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-locked.url = "github:nixos/nixpkgs?rev=12e7af1cfb3ab5bbbbd1d213a0b17c11ce9d3f2f";
    flake-utils.url = "github:numtide/flake-utils";
    yolov5s_bdd100k = {
      url = "github:williamhyin/yolov5s_bdd100k";
      flake = false;
    };
    yolov5 = {
      url = "github:ultralytics/yolov5?rev=4695ca8314269c9a9f4b8cf89c7962205f27fdad";
      flake = false;
    };
    torchvision-fasterrcnn.url = "github:junjihashimoto/torchvision-fasterrcnn";
  };
  outputs = { self,
              nixpkgs,
              nixpkgs-locked,
              flake-utils,
              yolov5s_bdd100k,
              yolov5,
              torchvision-fasterrcnn
            }:
    flake-utils.lib.eachDefaultSystem (system:
      let nixflow = import ./nix/nixflow.nix {pkgs=pkgs-locked;};
          pkgs = import nixpkgs {inherit system;};
          pkgs-locked = import nixpkgs-locked {inherit system;};
          cml = import ./utils/cml/default.nix {inherit pkgs;};
          huggingface = import ./models/huggingface/default.nix {inherit pkgs;};
          
          torchvision = import ./models/torchvision/default.nix {inherit pkgs;};
          fasterrcnn = torchvision-fasterrcnn.lib.${system};
          
          src2drv = import datasets/bdd100k-mini/default.nix {pkgs = pkgs-locked;};

          bdd100k-mini = src2drv {};
          bdd100k-mini-coco = import datasets/yolo2coco/default.nix {pkgs = pkgs-locked; dataset = bdd100k-mini; };
          yolo2coco = args@{...}: import datasets/yolo2coco/default.nix ({pkgs = pkgs-locked;} // args);
          img2coco = args@{...}: import datasets/img2coco/default.nix ({
            pkgs = pkgs-locked;
            inherit nixflow;
            datasetForLabels = bdd100k-mini-coco;
          } // args);

          
          yolov5 = import ./models/yolov5/default.nix {inherit pkgs;};
          yolov5-bdd100k = import ./models/yolov5/inferences/bdd100k.nix {inherit pkgs; inherit yolov5s_bdd100k;};
          yolov5-bdd100k-test = yolov5-bdd100k.test;
          yolov5-bdd100k-tests = nixflow.mapDatasets "test-" datasets.bdd100k-subset
            (dataset: 
              yolov5-bdd100k-test {
                inherit dataset;
                useDefaultWeights = true;
              }
            );
          fasterrcnn-bdd100k-tests = nixflow.mapDatasets "test-" datasets.bdd100k-subset
            (dataset: 
              fasterrcnn.test {
                datasets = yolo2coco {
                  inherit dataset;
                };
              }
            );
          datasets = rec{
            mnist = import datasets/mnist.nix {pkgs = pkgs-locked;};
            coco2014 = import datasets/coco/default.nix {pkgs = pkgs-locked;};
            bdd100k = import datasets/bdd100k/default.nix {pkgs = pkgs-locked;};
            bdd100k-coco = import datasets/yolo2coco/default.nix {pkgs = pkgs-locked; dataset = bdd100k; };
            bdd100k-mini = src2drv {};
            bdd100k-mini-coco = import datasets/yolo2coco/default.nix {pkgs = pkgs-locked; dataset = bdd100k-mini; };
            bdd100k-subset = import datasets/bdd100k-subset/subsets.nix {
              pkgs = pkgs-locked;
              inherit bdd100k;
            };
            sample-images = src2drv {
              srcs = builtins.map builtins.fetchurl (builtins.attrValues {
                data1 = {
                  url = "https://github.com/hasktorch/hasktorch-datasets/releases/download/sample/sample-images.zip";
                  sha256 = "1n065xabx4rv85b2nyvpj510yr3fvri1h828y77a1vr5g6mhrv7q";
                };
              });
            };
            sample-coco-images = img2coco {
              dataset = sample-images;
            };
          };
          analysis = rec {
            bdd100k-subset-yolov5 = import analysis/calc-map.nix {
              pkgs = pkgs-locked;
              datasets =
                (nixflow.flattenDerivations {
                  drvs = yolov5-bdd100k-tests;
                  prefix = "test-yolov5-bdd100k";
                }) // {
                  yolov5-bdd100k-all = yolov5-bdd100k-test {
                    dataset = datasets.bdd100k;
                    useDefaultWeights = true;
                  };
                }; 
            };
            bdd100k-subset-fasterrcnn = import analysis/calc-map-simple.nix {
              pkgs = pkgs-locked;
              datasets =
                (nixflow.flattenDerivations {
                  drvs = fasterrcnn-bdd100k-tests;
                  prefix = "test-fasterrcnn-bdd100k";
                }) // {
                  fasterrcnn-bdd100k-all =  fasterrcnn.test {
                    datasets = yolo2coco {
                      dataset = datasets.bdd100k;
                    };
                  };
                }; 
            };
            fasterrcnn-bdd100k-detect = fasterrcnn.detect {
              datasets = datasets.bdd100k-coco;
            };
          };
          
      in {
        # Exported functions.
        # ToDo: Generate documents for each function.
        lib = {
          datasets = {
            inherit yolo2coco;
            inherit img2coco;
            mix = args@{...}: import utils/mix.nix ({pkgs = pkgs-locked;} // args);
            bdd100k-filter = args@{...}: import datasets/bdd100k-subset/default.nix ({pkgs = pkgs-locked;} // args);
            bdd100k-subsets = args@{...}: {bdd100k = datasets.bdd100k;} // datasets.bdd100k-subset // args;
          };
          models = {
            yolov5-bdd100k = {
              test = args@{...}: yolov5-bdd100k.test ({
                useDefaultWeights = true;
              } // args);
            };
          };
          utils = nixflow;
        };

        # Exported packages.
        packages =
          with nixflow;
          (flattenDerivations {drvs = datasets; prefix = "datasets";})
          // (flattenDerivations {drvs = huggingface; prefix = "models-huggingface";})
          // (flattenDerivations {drvs = torchvision; prefix = "models-torchvision";})
          // (flattenDerivations {drvs = {yolov5 = yolov5;}; prefix = "models-yolov5";})
          // (flattenDerivations {drvs = yolov5-bdd100k-tests; prefix = "test-yolov5-bdd100k";})
          // (flattenDerivations {drvs = analysis; prefix = "analysis";})
          // {inherit cml;};
      }
    );
}
