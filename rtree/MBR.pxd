cimport numpy as cnp
ctypedef cnp.float64_t f64

cdef class MBR:
    cdef public f64[:] mins
    cdef public f64[:] maxs

    cdef bint is_overlapping(self, MBR o)
    cdef void enlarge(self, MBR r)
    cdef f64 volume(self)
    cdef f64 overlapped_volume(self, MBR r)
    cdef bint is_cover(self, MBR r)
    cdef f64 distance(self, MBR r)
