#!/usr/bin/env python

import os
import sys
from pathlib import Path
import imagesize
import csv
import json

bdd100k_out = sys.argv[1]
out = sys.argv[2]
classes = sys.argv[3]
#filter = sys.argv[4]

image_id = 1
annotation_id = 1

for m in ["trains", "valids"]:
    file_names = [
        Path(bdd100k_out + "/images/" + m).glob('*.jpg') ,
        Path(bdd100k_out + "/images/" + m).glob('*.png')]
    d={}
    d["images"]=[]
    d["annotations"]=[]
    d["categories"]=[]

    with open(classes) as f:
        for i, n in enumerate(f.read().splitlines()):
            d["categories"].append({
                "id": i,
                "name": n,
                "supercategory": n
            })
    
    for file_names0 in file_names:
        for file_name in file_names0:
            width, height = imagesize.get(file_name)
            d["images"].append({
                "file_name": str(file_name.name),
                "height": height,
                "width": width,
                "id": image_id
            })
            image_id = image_id + 1
    with open(out + '/annotations/' + m + '.json', 'w') as ff:
        json.dump(d, ff, indent=4)
