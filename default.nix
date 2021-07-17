let

  torchvision = import ./models/torchvision/default.nix {};
  huggingface = import ./models/huggingface/default.nix {};
  yolov5 = import ./models/yolov5/default.nix {};

in

{
  datasets = {
    mnist = import ./datasets/mnist.nix {};
  };

  models = {
    inherit torchvision;
    inherit huggingface;
    inherit yolov5;
  };
}
