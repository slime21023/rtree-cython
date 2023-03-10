cimport numpy as cnp
ctypedef cnp.float64_t f64

cdef class MBR:
    cdef public f64[:] mins
    cdef public f64[:] maxs

    cdef bint is_overlapping(self, Rect o)
    cdef void enlarge(self, Rect r)
    cdef f64 volume(self)
    cdef f64 overlapped_volume(self, Rect r)
    cdef bint is_cover(self, Rect r)
    cdef f64 distance(self, Rect r)
