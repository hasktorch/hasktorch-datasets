# Hasktorch Datasets (WIP)

This provides Nix-managed datasets, models, and Nix functions handing them.
Place them in the datasets, models, and utils directories.
Datasets and models are often placed in various places, but this repository behaves like a central repository for them.
In addition, we aim to build workflows and pipelines to integrate machine learning data, models, and software.

# Setup Datasets

The mnist data can be set up as follows.

```shell
nix-build -f https://github.com/hasktorch/hasktorch-datasets/archive/main.tar.gz datasets/mnist.nix -o data
```

# Setup Models

Build the resent18 torchscript model as follows.

```shell
nix-build -f https://github.com/hasktorch/hasktorch-datasets/archive/main.tar.gz models/torchvision.nix -A resnet18 -o resnet18
```

# Processing of datasets

The utils directory provides tools for mixing and annotating two different datasets.
