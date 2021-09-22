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
      let pkgs = nixpkgs.legacyPackages.${system};
          pkgs-locked = nixpkgs-locked.legacyPackages.${system};
          cml = import ./utils/cml/default.nix {inherit pkgs;};
          huggingface = import ./models/huggingface/default.nix {inherit pkgs;};
          
          torchvision = import ./models/torchvision/default.nix {inherit pkgs;};
          fasterrcnn = torchvision-fasterrcnn.lib.${system};

          yolo2coco = args@{...}: import datasets/yolo2coco/default.nix ({pkgs = pkgs-locked;} // args);

          
          yolov5 = import ./models/yolov5/default.nix {inherit pkgs;};
          yolov5-bdd100k = import ./models/yolov5/inferences/bdd100k.nix {inherit pkgs; inherit yolov5s_bdd100k;};
          yolov5-bdd100k-test = yolov5-bdd100k.test;
          mapDataset = prefix: datasets: f: builtins.listToAttrs (
            builtins.map (n:
              {
                name = prefix + n;
                value = f datasets."${n}";
              }
            ) (builtins.attrNames datasets)
          );
          yolov5-bdd100k-tests = mapDataset "test-" datasets.bdd100k-subset
            (dataset: 
              yolov5-bdd100k-test {
                inherit dataset;
                useDefaultWeights = true;
              }
            );
          fasterrcnn-bdd100k-tests = mapDataset "test-" datasets.bdd100k-subset
            (dataset: 
              fasterrcnn.test {
                datasets = yolo2coco {
                  inherit dataset;
                };
              }
            );
          src2drv = import datasets/bdd100k-mini/default.nix {pkgs = pkgs-locked;};
          datasets = rec{
            mnist = import datasets/mnist.nix {pkgs = pkgs-locked;};
            coco2014 = import datasets/coco/default.nix {pkgs = pkgs-locked;};
            bdd100k = import datasets/bdd100k/default.nix {pkgs = pkgs-locked;};
            bdd100k-coco = import datasets/yolo2coco/default.nix {pkgs = pkgs-locked; dataset = bdd100k; };
            bdd100k-mini = src2drv {};
            bdd100k-mini-coco = import datasets/yolo2coco/default.nix {pkgs = pkgs-locked; dataset = bdd100k-mini; };
            bdd100k-subset = import datasets/bdd100k-subset/subsets.nix {pkgs = pkgs-locked;};
            sample-images = src2drv {
              srcs = builtins.map builtins.fetchurl (builtins.attrValues {
                data1 = {
                  url = "https://github.com/hasktorch/hasktorch-datasets/releases/download/sample/sample-images.zip";
                  sha256 = "1n065xabx4rv85b2nyvpj510yr3fvri1h828y77a1vr5g6mhrv7q";
                };
              });
            };
          };
          analysis = rec {
            bdd100k-subset-yolov5 = import analysis/calc-map.nix {
              pkgs = pkgs-locked;
              datasets =
                (toPackages {
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
                (toPackages {
                  drvs = fasterrcnn-bdd100k-tests;
                  prefix = "test-yolov5-bdd100k";
                }) // {
                  fasterrcnn-bdd100k-all =  fasterrcnn.test {
                    datasets = yolo2coco {
                      dataset = datasets.bdd100k;
                    };
                  };
                }; 
            };
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
        # Exported functions.
        # ToDo: Generate documents for each function.
        lib = {
          datasets = {
            inherit src2drv;
            inherit yolo2coco;
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
          utils = {
            flattenDerivations = toPackages;
            excludeFiles = exclude_lists: src:
              builtins.filterSource
                (path: type: ! (builtins.any
                  (pattern:
                    builtins.isList (builtins.match pattern (baseNameOf path))
                  )
                  ([".*\.nix$"] ++ exclude_lists)
                ))
                src;
          };
        };

        # Exported packages.
        packages = (toPackages {drvs = datasets; prefix = "datasets";})
        // (toPackages {drvs = huggingface; prefix = "models-huggingface";})
        // (toPackages {drvs = torchvision; prefix = "models-torchvision";})
        // (toPackages {drvs = {yolov5 = yolov5;}; prefix = "models-yolov5";})
        // (toPackages {drvs = yolov5-bdd100k-tests; prefix = "test-yolov5-bdd100k";})
        // (toPackages {drvs = analysis; prefix = "analysis";})
        // {inherit cml;};
      }
    );
}
