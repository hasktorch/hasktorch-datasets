#!/usr/bin/env python

import os
import sys
from pathlib import Path
import imagesize
import csv
import json

bdd100k_out = sys.argv[1]
out = sys.argv[2]
#filter = sys.argv[3]

image_id = 0
annotation_id = 0

for m in ["trains", "valids"]:
    file_names = Path(bdd100k_out + "/images/" + m).glob('*.jpg')
    
    d={}
    d["images"]=[]
    d["annotations"]=[]
    
    for file_name in file_names:
        width, height = imagesize.get(file_name)
        d["images"].append({
            "file_name": str(file_name.name),
            "height": height,
            "width": width,
            "id": image_id
        })
        with open(str(file_name).replace('images','labels').replace('jpg','txt'), 'r') as f:
            reader = csv.reader(f, delimiter=' ')
            l = [row for row in reader]
            for i in l:
                category_id=int(i[0])
                cx = float(i[1]) * width
                cy = float(i[2]) * height
                w = float(i[3]) * width
                h = float(i[4]) * height
                x0 = cx - w/2
                y0 = cy - h/2
                d["annotations"].append({
                    "id": annotation_id,
                    "image_id": image_id,
                    "bbox":[
                        int(x0),
                        int(y0),
                        int(w),
                        int(h)
                    ],
                    "area": int(w)*int(h),
                    "iscrowd": 0,
                    "category_id": category_id,
                    "segmentation": []
                })
                annotation_id = annotation_id + 1
        image_id = image_id + 1
    with open(out + '/' + m + '.json', 'w') as ff:
        json.dump(d, ff, indent=4)
