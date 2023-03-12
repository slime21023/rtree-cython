cimport numpy as cnp
ctypedef cnp.float64_t f64
ctypedef cnp.npy_uint32 uint
from MBR cimport MBR

cdef class LeafEntry:
    cdef public MBR mbr
    cdef public object item

cdef class RNode:
    cdef public bint is_leaf
    cdef public uint level
    cdef public uint count

    # To handle the entries
    cdef MBR mbr
    cdef list items
    cdef list children
    
    cdef list search(self, MBR q)
    cdef RNode choose_leaf(self, MBR q)
    cdef tuple split_node(self)
    # cdef 

    # Insert Algorithms
    cdef void insert(self, MBR q, object item, uint max_size)
