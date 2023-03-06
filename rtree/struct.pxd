from cython cimport floating

cdef int MAX_ENTRIES=64


# For data reference
ctypedef object Item

cdef struct Rect:
    floating[:]  min
    floating[:]  max

cdef struct LeafNode:
    int count
    Rect[:] rects
    Item[:] items

cdef struct Node:
    int count
    Rect[:] rects
    Node[:] nodes

cdef struct Rtree:
    int count
    Node* 
