

__author__ = 'cleardusk'

import torch

from .models.faceboxes import FaceBoxesNet
from .utils.functions import load_model


def convert_to_onnx(onnx_path):
    pretrained_path = onnx_path.replace('.onnx', '.pth')
    torch.set_grad_enabled(False)
    net = FaceBoxesNet(phase='test', size=None, num_classes=2)  
    net = load_model(net, pretrained_path=pretrained_path, load_to_cpu=True)
    net.eval()

    batch_size = 1
    dummy_input = torch.randn(batch_size, 3, 720, 1080)
    torch.onnx.export(
        net,
        (dummy_input,),
        onnx_path,
        input_names=['input'],
        output_names=['output'],
        do_constant_folding=True
    )
    print(f'Convert {pretrained_path} to {onnx_path} done.')