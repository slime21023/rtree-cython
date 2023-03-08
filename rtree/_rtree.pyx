from libc.stdlib cimport malloc, free
cimport numpy as cnp
ctypedef cnp.float64_t f64
ctypedef cnp.npy_uint32 uint

cdef class Rect:
    cdef public f64[:] mins
    cdef public f64[:] maxs

    def __cinit__(self, f64[:] mins, f64[:] maxs):
        self.mins = mins.copy()
        self.maxs = maxs.copy()

    cdef bint is_overlapping(self, Rect o):
        cdef int dim = 0
        cdef bint result = True
        cdef bint condition_one = True
        cdef bint condition_two = True
        
        for dim in range(self.mins.shape[0]):
            condition_one = not (o.mins[dim] <= self.mins[dim] and self.mins[dim] <= o.maxs[dim])
            condition_two = not (self.mins[dim] <= o.mins[dim] and o.mins[dim] <= self.maxs[dim])
            if not (condition_one or condition_two):
                result = False
                break
        
        return result


cdef class RNode:
    """
    The R-tree Node (non-leaf node and leaf node)
    """
    def __cinit__(self, bint is_leaf=true, uint max_children):
        self.is_leaf = is_leaf
        if not is_leaf:
            self.children = <RNode *> malloc(max_children * sizeof(RNode))

    def __dealloc__(self):
        if not self.is_leaf:
            free(self.children)
    



cdef class _Rtree:
    """
    The R-tree implement with cython
    """

    def __cinit__(self, uint n_dims, uint min_children, uint max_children):
        self.n_dims = n_dims
        self.min_children = min_children
        self.max_children = max_children
        self.root = create_rnode(max_children)

    def __dealloc__(self):
        """Destructor."""
        # Free all inner structures
        free_rnode(self.root, self.max_children)
