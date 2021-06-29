{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
with pkgs;
let
  huggingface = import ./models/huggingface/default.nix {};
  yolov5 = import ./models/yolov5/default.nix {};
in
{
  datasets = {
    mnist = import ./datasets/mnist.nix {};
  };
  models = {
    torchvision = import ./models/torchvision/default.nix {};
    inherit huggingface;
    inherit yolov5;
  };
}
