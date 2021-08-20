#!/usr/bin/env bash

version=2014
hashfile=binary-hashes.nix
rm -f $hashfile
echo "{}: {" >> $hashfile
URLs="
https://github.com/hasktorch/hasktorch-datasets/releases/download/coco2014/5k.part
https://github.com/hasktorch/hasktorch-datasets/releases/download/coco2014/instances_train-val2014.zip
https://github.com/hasktorch/hasktorch-datasets/releases/download/coco2014/labels.tgz
https://github.com/hasktorch/hasktorch-datasets/releases/download/coco2014/trains2014_1.zip
https://github.com/hasktorch/hasktorch-datasets/releases/download/coco2014/trains2014_2.zip
https://github.com/hasktorch/hasktorch-datasets/releases/download/coco2014/trains2014_3.zip
https://github.com/hasktorch/hasktorch-datasets/releases/download/coco2014/trains2014_4.zip
https://github.com/hasktorch/hasktorch-datasets/releases/download/coco2014/trains2014_5.zip
https://github.com/hasktorch/hasktorch-datasets/releases/download/coco2014/trains2014_6.zip
https://github.com/hasktorch/hasktorch-datasets/releases/download/coco2014/trains2014_7.zip
https://github.com/hasktorch/hasktorch-datasets/releases/download/coco2014/trainvalno5k.part
https://github.com/hasktorch/hasktorch-datasets/releases/download/coco2014/val2014_1.zip
https://github.com/hasktorch/hasktorch-datasets/releases/download/coco2014/val2014_2.zip
https://github.com/hasktorch/hasktorch-datasets/releases/download/coco2014/val2014_3.zip
https://github.com/hasktorch/hasktorch-datasets/releases/download/coco2014/val2014_4.zip
"

for url in $URLs;do
    hash=$(nix-prefetch-url $url)
    filename=`basename $url`
    name=`echo $filename | sed -e 's/\\./_/g'`
    echo "${name} = {" >> $hashfile
    echo "  url = \"$url\";" >> $hashfile
    echo "  sha256 = \"$hash\";" >> $hashfile
    echo "};" >> $hashfile
done
echo "}" >> $hashfile
