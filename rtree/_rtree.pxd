cimport numpy as cnp
ctypedef cnp.float64_t f64
ctypedef cnp.npy_uint32 uint


cdef class _Rtree:
    cdef public uint n_dims      # Number of dimensions 
    cdef public uint max_children
    cdef public uint min_children
    cdef public uint height
    cdef RNode* root

    cpdef public list search(self, Rect r)
    cpdef public void insert(self, Rect r, object item)
    cpdef public void delete(self, Rect r, object item)
    cpdef public list search_datapoint(self, f64[:] key)
    cpdef public void insert_datapoint(self, f64[:] key, object value)
    cpdef public void delete_datapoint(self, f64[:] key, object value)