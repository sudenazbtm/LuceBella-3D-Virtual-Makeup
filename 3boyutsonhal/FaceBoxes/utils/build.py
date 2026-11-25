








import os
from os.path import join as pjoin
import numpy as np
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext


def find_in_path(name, path):
    "Find a file in a search path"
    for dir in path.split(os.pathsep):
        binpath = pjoin(dir, name)
        if os.path.exists(binpath):
            return os.path.abspath(binpath)
    return None



try:
    numpy_include = np.get_include()
except AttributeError:
    numpy_include = np.get_numpy_include()



class custom_build_ext(build_ext):
    def build_extensions(self):
        build_ext.build_extensions(self)


ext_modules = [
    Extension(
        "nms.cpu_nms",
        ["nms/cpu_nms.pyx"],
        extra_compile_args=["-Wno-cpp", "-Wno-unused-function"],
        include_dirs=[numpy_include]
    )
]

setup(
    name='mot_utils',
    ext_modules=ext_modules,
    cmdclass={'build_ext': custom_build_ext},
)