








try:
    from .nms.cpu_nms import cpu_nms, cpu_soft_nms
except ImportError:
    pass 



def nms(dets, thresh):

    if dets.shape[0] == 0:
        return []
    try:
        return cpu_nms(dets, thresh)
    except NameError:
        from .nms.py_cpu_nms import py_cpu_nms
        return py_cpu_nms(dets, thresh)