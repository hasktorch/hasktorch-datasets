{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
with pkgs;
{
  datasets = {
    mnist = import ./datasets/mnist.nix {};
  };
  models = {
    torchvision = import ./models/torchvision/default.nix {};
  };
}
