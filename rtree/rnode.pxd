cimport numpy as cnp
ctypedef cnp.float64_t f64
ctypedef cnp.npy_uint32 uint
from rect cimport Rect  

cdef class RNode:
    cdef public bint is_leaf
    cdef public uint level
    cdef public uint count

    # R-tree node entry(leaf and non-leaf node)
    cdef Rect rect
    cdef list items
    cdef list children
    
    cdef list search(self, Rect r)

    # Insert Algorithms
    cdef void insert(self, Rect r, object item)
    