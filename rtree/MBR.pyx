cdef class MBR:
    def __cinit__(self, f64[:] mins, f64[:] maxs):
        self.mins = mins.copy()
        self.maxs = maxs.copy()

    cdef bint is_overlapping(self, Rect o):
        cdef int dim = 0
        cdef bint result = True
        cdef bint condition_one = True
        cdef bint condition_two = True
        
        for dim in range(self.mins.shape[0]):
            condition_one = self.mins[dim] >= o.mins[dim] and self.mins[dim] <= o.maxs[dim]
            condition_two = self.maxs[dim] >= o.mins[dim] and self.maxs[dim] <= o.maxs[dim]
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

    cdef f64 volume(self):
        cdef f64 v = 1
        cdef int dim = 0
        for dim in range(self.mins.shape[0]):
        v *= (self.maxs[dim] - self.mins[dim])

        return v
    
    cdef f64 overlapped_volume(self, Rect r):
        cdef f64 v = 1
        cdef int dim = 0
        cdef f64 cur_min, cur_max
        if not self.is_overlapping(r):
        return 0
        else:
        for dim in range(self.mins.shape[0]):
            cur_min = self.mins[dim] if self.mins[dim] > r.mins[dim] else r.mins[dim]
            cur_max = self.maxs[dim] if self.maxs[dim] < r.maxs[dim] else r.maxs[dim]
            v *= (cur_max - cur_min)
        return v

    cdef bint is_cover(self, Rect r):
        cdef int dim = 0
        cdef bint result = True
        for dim in range(self.mins.shape[0]):
        if not ((self.mins[dim] <= r.mins[dim]) and (self.maxs[dim] >= r.maxs[dim])):
            result = False
            break
        return result

    cdef f64 distance(self, Rect r):
        cdef f64 d = 0
        cdef int dim = 0
        cdef f64 temp1, temp2
        if self.is_overlapping(r):
            return 0
        else:
            for dim in range(self.mins.shape[0]):
                # find the shortest distance in the dimension
                temp1 = abs(self.mins[dim] - r.maxs[dim])
                temp2 = abs(r.mins[dim] - self.maxs[dim])
                if temp1 < temp2:
                    d += temp1
                else:
                    d += temp2
        return d