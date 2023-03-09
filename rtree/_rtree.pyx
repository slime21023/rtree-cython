from libc.stdlib cimport malloc, free
cimport numpy as cnp
ctypedef cnp.float64_t f64
ctypedef cnp.npy_uint32 uint

cdef class _Rtree:
    """
    The R-tree implement with cython
    """

    def __cinit__(self, uint n_dims, uint min_children, uint max_children):
        self.n_dims = n_dims
        self.min_children = min_children
        self.max_children = max_children
        self.root = RNode(max_children=max_children)

    def __dealloc__(self):
        """Destructor."""
        # Free all inner structures
        free_rnode(self.root, self.max_children)

    cpdef public list search(self, Rect r):
        return self.root.search(r)

    cpdef public list search_datapoint(self, f64[:] key):
        cdef Rect r = Rect(key, key)
        return self.root.search(r)