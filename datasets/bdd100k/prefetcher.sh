#!/usr/bin/env bash

version=2014
hashfile=binary-hashes.nix
rm -f $hashfile
echo "{}: {" >> $hashfile
URLs="
https://github.com/hasktorch/hasktorch-datasets/releases/download/bdd100k/bdd100k_1.zip
https://github.com/hasktorch/hasktorch-datasets/releases/download/bdd100k/bdd100k_2.zip
https://github.com/hasktorch/hasktorch-datasets/releases/download/bdd100k/bdd100k_3.zip
https://github.com/hasktorch/hasktorch-datasets/releases/download/bdd100k/bdd100k_labels.zip
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
