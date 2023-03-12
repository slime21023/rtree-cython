
cdef class LeafEntry:
    def __cinit__(self, MBR mbr, object item):
        self.mbr = mbr
        self.item = item


cdef class RNode:
    """
    The R-tree Node (non-leaf node and leaf node)
    """
    def __cinit__(self, MBR mbr, bint is_leaf=True):
        self.is_leaf = is_leaf
        self.mbr = mbr
        self.count = 0
        if not is_leaf:
            self.children = []
        else:
            self.items = []
    
    cdef list search(self, MBR q):
        cdef int idx =0
        cdef list result = []
        if not self.mbr.is_overlapping(q):
            return result

        if self.is_leaf:
            for idx in range(len(self.items)):
                if q.is_overlapping(self.items[idx].mbr):
                    result.append(self.items[idx])
            return result
        else:
            for idx in range(len(self.children)):
                result += self.children[idx].search(q)
            return result

    cdef RNode choose_leaf(self, MBR q):
        cdef int idx = 0

        if self.is_leaf:
            return self
        else:
            for idx in range(len(self.children)):
                self.children[idx].enlarge(r)
            
            return self.children[idx].choose_leaf(r)

    cdef void insert(self, MBR r, object item, uint max_size):
        cdef RNode node = choose_leaf(self)

        node.items.append(item)
        if node.count > max_children:
            l, ll = node.split_node() 
            