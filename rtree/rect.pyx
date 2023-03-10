cdef class Rect:
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

    cdef void enlarge(self, Rect r):
        cdef int dim = 0
        for dim in range(self.mins.shape[0]):
            if r.mins[dim] < self.mins[dim]:
                self.mins[dim] = r.mins[dim] - 25.0
            if r.maxs[dim] > self.maxs[dim]:
                self.maxs[dim] = r.maxs[dim] + 25.0

            