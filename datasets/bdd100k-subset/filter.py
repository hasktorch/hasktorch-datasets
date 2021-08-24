#!/usr/bin/env python

import os
import sys
from pathlib import Path
import ijson

bdd100k_out = sys.argv[1]
out = sys.argv[2]
#filter = sys.argv[3]

for i in ["images", "labels"]:
  for j in ["trains", "valids"]:
      os.makedirs(out + "/" + i + "/" + j)

os.symlink(bdd100k_out + "/bdd100k.names", out + "/bdd100k.names")

file_names = Path(bdd100k_out).glob('bdd100k_labels_images_*.json')

for file_name in file_names:
    if "val" in str(file_name):
        dir="valids"
    elif "train" in str(file_name):
        dir="trains"
    else:
        dir="other"
    f = open(file_name)
    objects = ijson.items(f, 'item')
    for part in objects:
        filename=part['name']
        weather=part['attributes']['weather']
        scene=part['attributes']['scene']
        timeofday=part['attributes']['timeofday']
#        if eval(filter):
        if __filter__:
          os.symlink(bdd100k_out+"/images/"+dir+"/"+filename,out+"/images/"+dir+"/"+filename)
          os.symlink(bdd100k_out+"/labels/"+dir+"/"+filename,out+"/labels/"+dir+"/"+filename)
