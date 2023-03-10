

cdef class RNode:
    """
    The R-tree Node (non-leaf node and leaf node)
    """
    def __cinit__(self, Rect r, bint is_leaf=True):
        self.is_leaf = is_leaf
        self.count = 0
        self.rect = r
        if not is_leaf:
            self.children = []
        else:
            self.items = []
    
    cdef public list search(self, Rect r):
        cdef int idx =0
        if not self.rect.is_overlapping(r):
            return []

        if self.is_leaf:
            return self.items
        else:
            result = []
            for idx in range(self.count):
                result += self.children[idx].search(r)
            return result

    cdef RNode choose_leaf(self, Rect r):
        cdef int idx = 0

        if self.is_leaf:
            return self
        else:
            for idx in range(len(self.children)):
                self.children[idx].enlarge(r)
            
            return self.children[idx].choose_leaf(r)

    cdef void insert(self, Rect r, object item, uint max_size):
        cdef RNode node = choose_leaf(self)

        node.items.append(item)
        if node.count > max_children:
            l, ll = node.split_node() 
            