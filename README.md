# Hasktorch Datasets (WIP)

This provides Nix-managed datasets, models, and Nix functions handing them.
Place them in the datasets, models, and utils directories.
Datasets and models are often placed in various places, but this repository behaves like a central repository for them.
In addition, we aim to build workflows and pipelines to integrate machine learning data, models, and software.

# Setup Datasets

The mnist data can be set up as follows.

```shell
nix-build https://github.com/hasktorch/hasktorch-datasets/archive/<git-hash>.tar.gz -A datasets.mnist -o data
```

# Setup Models

Build the resent18 torchscript model as follows.

```shell
nix-build https://github.com/hasktorch/hasktorch-datasets/archive/<git-hash>.tar.gz -A models.torchvision.resnet18 -o resnet18 --option sandbox false
```

# Processing of datasets

The utils directory provides tools for mixing and annotating two different datasets.
