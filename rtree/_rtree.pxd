cimport numpy as np

ctypedef cnp.npy_float32 float32
ctypedef cnp.npy_uint32 uint

cdef struct Rect:
    floating[:]  min
    floating[:]  max

# R-tree entry(leaf and non-leaf node)
cdef struct RNode:
    bool is_leaf
    uint level
    uint count
    Rect rect
    list items
    RNode* children

cdef RNode* create_rnode(uint max_children)
cdef void free_rnode(RNode* node, uint max_children)

cdef class _Rtree:
    cdef public uint n_dims      # Number of dimensions 
    cdef public uint max_children
    cdef public uint min_children
    cdef public uint height
    cdef RNode* root

    cdef list search(self, Rect r)
    cdef void insert(self, Rect r, object item)
    cdef RNode* choose_leaf(self, Rect r, object item)
    cdef void adjust_tree(self, RNode* leaf)
    cdef void delete(self, Rect r, object item)
    cdef RNode* find_leaf(self, Rect r, object item)
    cdef void condense_tree(self, RNode* leaf)
    cdef RNode* split(self, RNode* leaf)
    cdef (RNode*, RNode*) pick_seeds(self, RNode* leaf)
    cdef RNode* PickNext(self, RNode* g1, RNode* g2)
