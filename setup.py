from setuptools import Extension, setup, find_packages
from Cython.Build import cythonize
import numpy

ext_modules = [
    Extension(
        "RTreeCy",
        sources=["rtree/RTree.pyx"],
        include_dirs=[numpy.get_include()],
    )
]

setup(
    name="RTreeCy",
    packages=find_packages(exclude=("algo",)),
    include_dirs=[numpy.get_include()],
    ext_modules=cythonize(ext_modules),
    package_dir = {'': 'lib'}
)