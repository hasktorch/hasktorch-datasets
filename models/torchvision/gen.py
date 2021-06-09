import sys
import torch
import torchvision

import torchvision.models as models

import ssl
ssl._create_default_https_context = ssl._create_unverified_context

modelName = sys.argv[1];
torch.hub.DEFAULT_CACHE_DIR=sys.argv[2];

model = eval("models."+modelName+"(pretrained=True)")

example = torch.rand(1, 3, 224, 224)

model.eval()

traced_script_module = torch.jit.trace(model, example)
traced_script_module.save(modelName + ".pt")
