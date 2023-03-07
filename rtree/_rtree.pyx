from libc.stdlib cimport malloc, free
cimport numpy as cnp

ctypedef cnp.npy_float32 float32
ctypedef cnp.npy_uint32 uint

cdef RNode* create_rnode(uint max_children, is_leaf=true):
    cdef RNode* node = <Rect *>malloc(sizeof(RNode))
    if not is_leaf:
        node.children = <Rect *>malloc(sizeof(RNode) * max_children )
    return node

cdef void free_rnode(RNode* node, uint max_children):
    if not node.is_leaf:
        for i in range(max_children):
            free_rnode(node.children[i], max_children)
    free(node)


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

    cdef list search(self, Rect r):
        
         

    cdef void inset(self, Rect r, object item):
                
            
