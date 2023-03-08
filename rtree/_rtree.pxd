cimport numpy as cnp
ctypedef cnp.float64_t f64
ctypedef cnp.npy_uint32 uint

cdef class Rect:
    cdef public f64[:] mins
    cdef public f64[:] maxs
    cdef bint is_overlapping(self, Rect o)


cdef class RNode:
    cdef bint is_leaf
    cdef uint level
    cdef uint count

    # R-tree node entry(leaf and non-leaf node)
    cdef Rect rect
    cdef list items
    cdef RNode* children

    


cdef class _Rtree:
    cdef public uint n_dims      # Number of dimensions 
    cdef public uint max_children
    cdef public uint min_children
    cdef public uint height
    cdef RNode* root

    cdef public list search(self, Rect r)
    cdef public void insert(self, Rect r, object item)
    cdef public void delete(self, Rect r, object item)
    cdef public list search_datapoint(self, f64[:] key)
    cdef public void insert_datapoint(self, f64[:] key, object value)
    cdef public void delete_datapoint(self, f64[:] key, object value)