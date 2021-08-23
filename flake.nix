{
  description = "Datasets";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-locked.url = "github:nixos/nixpkgs?rev=12e7af1cfb3ab5bbbbd1d213a0b17c11ce9d3f2f";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, nixpkgs-locked, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          pkgs-locked = nixpkgs-locked.legacyPackages.${system};
      in {
        packages.datasets-mnist = import datasets/mnist.nix {pkgs = pkgs-locked;};
        packages.datasets-coco2014 = import datasets/coco/default.nix {pkgs = pkgs-locked;};
      }
    );
}
