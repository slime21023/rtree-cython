cimport numpy as cnp
ctypedef cnp.float64_t f64

cdef class Rect:
    cdef public f64[:] mins
    cdef public f64[:] maxs
    cdef bint is_overlapping(self, Rect o)
    cdef void enlarge(self, Rect r)

