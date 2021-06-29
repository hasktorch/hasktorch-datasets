# Hasktorch Datasets (WIP)

This provides Nix-managed datasets, models, and Nix functions handing them.
Place them in the datasets, models, and utils directories.
Datasets and models are often placed in various places, but this repository behaves like a central repository for them.
In addition, we aim to build workflows and pipelines to integrate machine learning data, models, and software.

# Setup Datasets

The mnist data can be set up as follows.

```shell
$ nix-build https://github.com/hasktorch/hasktorch-datasets/archive/<git-hash>.tar.gz -A datasets.mnist -o data
```

# Setup Models

Build torchscript models as follows.

```shell
# Resnet18
$ nix-build https://github.com/hasktorch/hasktorch-datasets/archive/<git-hash>.tar.gz -A models.torchvision.resnet18 -o resnet18 --option sandbox false

# Yolov5s
$ nix-build https://github.com/hasktorch/hasktorch-datasets/archive/<git-hash>.tar.gz -A models.yolov5 -o yolov5 --option sandbox false

# Speech2Text
$ nix-build https://github.com/hasktorch/hasktorch-datasets/archive/e035e056b3a0827bdf1d7192afee85c88b340b74.tar.gz -A models.huggingface.speech2text-small-librispeech-asr-trace -o speech2txt --option sandbox false
```

# Processing of datasets

The utils directory provides tools for mixing and annotating two different datasets.

```shell
$ cat << EOF > datasets-1to1.nix
{rate}:
import ./utils/mix.nix {
    datasetA = import ./datasets/a.nix {};
    datasetB = import ./datasets/b.nix {};
    rate = rate;
};
EOF
$ nix-build --arg rate 0.5 -o mixed-datasets ./datasets-1to1.nix
```

