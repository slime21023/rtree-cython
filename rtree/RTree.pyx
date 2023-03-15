# cython: language_level=3, boundscheck=False
import numpy as np
cimport numpy as cnp
ctypedef cnp.float64_t f64
ctypedef cnp.npy_uint32 uint

cdef class MBR:
    cdef public f64[:] mins
    cdef public f64[:] maxs

    def __cinit__(self, f64[:] mins, f64[:] maxs):
        self.mins = mins.copy()
        self.maxs = maxs.copy()

    cpdef bint is_overlapping(self, MBR o):
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

    cpdef void enlarge(self, MBR r):
        cdef int dim = 0
        for dim in range(self.mins.shape[0]):
            if r.mins[dim] < self.mins[dim]:
                self.mins[dim] = r.mins[dim] - 25.0
            if r.maxs[dim] > self.maxs[dim]:
                self.maxs[dim] = r.maxs[dim] + 25.0

    cpdef f64 volume(self):
        cdef f64 v = 1
        cdef int dim = 0
        for dim in range(self.mins.shape[0]):
            v *= (self.maxs[dim] - self.mins[dim])

        return v

    cpdef f64 overlapped_volume(self, MBR r):
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

    cpdef bint is_cover(self, MBR r):
        cdef int dim = 0
        cdef bint result = True
        for dim in range(self.mins.shape[0]):
            if not ((self.mins[dim] <= r.mins[dim]) and (self.maxs[dim] >= r.maxs[dim])):
                result = False
                break
        return result

    cpdef f64 distance(self, MBR r):
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

    cpdef copy(self):
        return MBR(self.mins, self.maxs)

cdef class LeafEntry:
    cdef public MBR mbr
    cdef public object item

    def __cinit__(self, MBR mbr, object item):
        self.mbr = mbr
        self.item = item

    cpdef bint is_same(self, LeafEntry o):
        cdef int idx = 0
        cdef bint same = True

        for dim in range(self.mbr.mins.shape[0]):
            if o.mbr.mins[dim] != self.mbr.mins[dim]:
                same = False
                break
            if o.mbr.maxs[dim] != self.mbr.maxs[dim]:
                same = False
                break
        return same


cdef class RNode:
    cdef public bint is_leaf

    # To handle the entries
    cdef public MBR mbr
    cdef public list items
    cdef public list children

    def __cinit__(self, MBR mbr, bint is_leaf=True):
        self.is_leaf = is_leaf
        self.mbr = mbr
        if not is_leaf:
            self.children = []
        else:
            self.items = []

    cpdef list search(self, MBR q):
        cdef int idx = 0
        cdef list result = []
        if not (self.mbr.is_overlapping(q) or self.mbr.is_cover(q)):
            return result

        if self.is_leaf:
            for idx in range(len(self.items)):
                if q.is_overlapping(self.items[idx].mbr):
                    result.append(self.items[idx])
                elif q.is_cover(self.items[idx].mbr):
                    result.append(self.items[idx])
                elif self.items[idx].mbr.is_cover(q):
                    result.append(self.items[idx])
            return result
        else:
            for idx in range(len(self.children)):
                result += self.children[idx].search(q)
            return result


    cpdef RNode choose_leaf(self, MBR q):
        cdef int idx = 0
        cdef int selected = -1
        cdef f64 temp, calc

        self.mbr.enlarge(q)
        if self.is_leaf:
            return self
        else:
            for idx in range(len(self.children)):
                calc = self.children[idx].mbr.overlapped_volume(q)
                if calc > temp:
                    temp = calc
                    selected = idx

            if selected == -1:
                idx = 0
                calc = 0
                temp = 0
                for idx in range(len(self.children)):
                    calc = self.children[idx].mbr.distance(q)
                    if idx == 0:
                        temp = calc
                        selected = idx

                    if calc < temp:
                        temp = calc
                        selected = idx

            return self.children[selected].choose_leaf(q)

    cpdef tuple pick_seeds(self):
        cdef int idx = 0
        cdef list seeds = []
        cdef bint is_overlapping = True
        cdef int seed_one = -1
        cdef int seed_two = -1
        cdef int calc = 0
        cdef int temp = 0

        if self.is_leaf:
            seeds += self.items
        else:
            seeds += self.children

        # check are all overlapping
        for idx in range(1, len(seeds)):
            if not seeds[0].mbr.is_overlapping(seeds[idx].mbr):
                is_overlapping = False
                break

        if not is_overlapping:
            for idx in range(len(seeds) - 1):
                for j in range(idx + 1, len(seeds)):
                    calc = seeds[idx].mbr.distance(seeds[j].mbr)
                    if calc > temp:
                        temp = calc
                        seed_one = idx
                        seed_two = j

        if is_overlapping:
            for idx in range(len(seeds) - 1):
                for j in range(idx + 1, len(seeds)):
                    if idx == 0:
                        temp = seeds[idx].mbr.overlapped_volume(seeds[j].mbr)
                        seed_one = idx
                        seed_two = j

                    calc = seeds[idx].mbr.overlapped_volume(seeds[j].mbr)
                    if calc < temp:
                        temp = calc
                        seed_one = idx
                        seed_two = j

        return (seed_one, seed_two)

    cpdef void split_leaf(self):
        cdef int idx = 0
        cdef bint is_overlapping_with_g1 = False
        cdef bint is_overlapping_with_g2 = False

        if not self.is_leaf:
            return

        s1, s2 = self.pick_seeds()

        # create two leaf nodes
        e1 = self.items.pop(s1)
        e2 = self.items.pop(s2 - 1)

        g1 = RNode(e1.mbr.copy(), is_leaf=True)
        g1.items.append(e1)

        g2 = RNode(e2.mbr.copy(), is_leaf=True)
        g2.items.append(e2)

        # insert the entries to new leaf nodes
        for idx in range(len(self.items)):
            item = self.items.pop()
            is_overlapping_with_g1 = item.mbr.is_overlapping(g1.mbr)
            is_overlapping_with_g2 = item.mbr.is_overlapping(g2.mbr)

            if is_overlapping_with_g1 and is_overlapping_with_g2:
                if item.mbr.overlapped_volume(g1.mbr) >= item.mbr.overlapped_volume(g2.mbr):
                    g1.items.append(item)
                    g1.mbr.enlarge(item.mbr)
                else:
                    g2.items.append(item)
                    g2.mbr.enlarge(item.mbr)

            elif is_overlapping_with_g1:
                g1.items.append(item)
                g1.mbr.enlarge(item.mbr)
            elif is_overlapping_with_g2:
                g2.items.append(item)
                g2.mbr.enlarge(item.mbr)
            else:
                # if not overlapping case, select smallest distance to insert
                if item.mbr.distance(g1.mbr) < item.mbr.distance(g2.mbr):
                    g1.items.append(item)
                    g1.mbr.enlarge(item.mbr)
                else:
                    g2.items.append(item)
                    g2.mbr.enlarge(item.mbr)

        self.mbr.enlarge(g1.mbr)
        self.mbr.enlarge(g2.mbr)
        self.children = [g1, g2]
        self.items = []
        self.is_leaf = False


    cpdef void split_node(self, RNode parent):
        cdef int idx = 0
        cdef bint is_overlapping_with_g1 = False
        cdef bint is_overlapping_with_g2 = False
        cdef bint is_root = (self == parent)

        if self.is_leaf == True:
            return
		
        s1, s2 = self.pick_seeds()

        # create two leaf node
        e1 = self.children.pop(s1)
        e2 = self.children.pop(s2 - 1)

        g1 = RNode(e1.mbr, is_leaf=False)
        g1.children.append(e1)

        g2 = RNode(e2.mbr, is_leaf=False)
        g2.children.append(e2)
		
        # insert the entries to new leaf nodes
        for idx in range(len(self.children)):
            child = self.children.pop()
            is_overlapping_with_g1 = child.mbr.is_overlapping(g1.mbr)
            is_overlapping_with_g2 = child.mbr.is_overlapping(g2.mbr)

            if is_overlapping_with_g1 and is_overlapping_with_g2:
                if child.mbr.overlapped_volume(g1.mbr) >= child.mbr.overlapped_volume(g2.mbr):
                    g1.children.append(child)
                    g1.mbr.enlarge(child.mbr)
                else:
                    g2.children.append(child)
                    g2.mbr.enlarge(child.mbr)

            elif is_overlapping_with_g1:
                g1.children.append(child)
                g1.mbr.enlarge(child.mbr)
            elif is_overlapping_with_g2:
                g2.children.append(child)
                g2.mbr.enlarge(child.mbr)
            else:
                # if not overlapping case, select smallest distance to insert
                if child.mbr.distance(g1.mbr) < child.mbr.distance(g2.mbr):
                    g1.children.append(child)
                    g1.mbr.enlarge(child.mbr)
                else:
                    g2.children.append(child)
                    g2.mbr.enlarge(child.mbr)
		
        if not is_root:
            parent.children += [g1, g2]
        else:
            self.children = [g1, g2]


    cpdef void adjust_tree(self, RNode parent, uint max_size):
        cdef int idx = 0
        cdef list temp = []
        cdef bint has_leaf = False
        cdef bint has_node = False

        if self.is_leaf == True:
            return
        else:
            for idx in range(len(self.children)):
                self.children[idx].adjust_tree(self, max_size)
            
            # check if all children are leafnode or not
            # and check if all children are node or not
            for idx in range(len(self.children)):
                if not self.children[idx].is_leaf:
                    has_node = True
                else:
                    has_leaf = True

            if has_leaf and has_node:
                for idx in range(len(self.children)):
                    if not self.children[idx].is_leaf:
                        temp.append(self.children[idx])
			
                # remove the non leaf from this node
                for idx in range(len(temp)):
                    self.children.remove(temp[idx])
                parent.children += temp
		
            # check the size of children
            if int(len(self.children)) > max_size:
                print("split")
                self.split_node(parent)
   

    cpdef void insert(self, LeafEntry item, uint max_size):
        cdef RNode leaf
        
        leaf = self.choose_leaf(item.mbr)
        leaf.items.append(item)

        if len(leaf.items) > max_size:
            leaf.split_leaf()
            
        self.adjust_tree(self, max_size)
  

    cpdef list find_leaf(self, MBR mbr):
        cdef int idx = 0
        cdef list result =[]

        if self.mbr.is_cover(mbr) and self.is_leaf:
            result.append(self)
            return result
            
        if self.mbr.is_cover(mbr) and not self.is_leaf:
            for idx in range(len(self.children)):
                result += self.children[idx].find_leaf(mbr)
            
        return result

    cpdef  void remove_leaf(self, RNode leaf):
        cdef int  idx = 0
        cdef bint  is_contain = False

        if self.is_leaf:
            return
            
        for idx in range(len(self.children)):
            if self.children[idx].mbr.is_cover(leaf.mbr):
                self.children[idx].remove(leaf)

            if self.children[idx] == leaf:
                is_contain = True
        
        self.children.remove(leaf)
  
    cpdef  bint remove_entry(self, LeafEntry leaf):
        cdef int idx = 0
        cdef int selected = -1

        if not self.is_leaf:
            return False
            
        for idx in range(len(self.items)):
            if self.items[idx].is_same(leaf):
                selected = idx
                break
        if selected != -1:
            self.items.pop(selected)
            return True
        else:
            return False

    cpdef  void condense_tree(self, RNode leaf, uint min_size, uint max_size):
        cdef  list  temp = []
        cdef  int   idx =  0
        
        if not leaf.is_leaf:
            return
            
        if len(leaf.items) < min_size:
            temp += leaf.items
        self.remove_leaf(leaf)

        for idx in range(len(temp)):
            self.insert(temp[idx], max_size)
   
    cpdef  void delete(self, LeafEntry entry,  uint  min_size,  uint max_size):
        cdef  list  temp =  []
        cdef  int  idx = 0
        cdef  RNode leaf  =  None
    
        temp += self.find_leaf(entry.mbr)
		
		# remove the entry
        for idx in range(len(temp)):
            if temp[idx].remove_entry(entry):
                leaf = temp[idx]
                break
		
        if leaf != None:
            self.condense_tree(leaf, min_size, max_size)

        # set the only child to the root
        if not self.is_leaf and len(self.children) == 1:  
            self.children = self.children[0].children


cdef class RTree:
    cdef public uint n_dims
    cdef public uint max_children
    cdef public uint min_children

    cdef RNode root

    def __cinit__(self, uint min_children, uint max_children, uint n_dims = 2):
        self.n_dims = n_dims
        self.min_children = min_children
        self.max_children = max_children
        self.root = None

    cpdef list search(self, MBR mbr):
        if self.root == None:
            return []

        return self.root.search(mbr)

    cpdef void insert(self, LeafEntry entry):
        if self.root == None:
            self.root = RNode(entry.mbr.copy())
        
        self.root.insert(entry, self.max_children)

    cpdef void delete(self, LeafEntry entry):
        if self.root == None:
            return
        self.root.delete(entry, self.min_children, self.max_children)

    cpdef list search_datapoint(self, f64[:] key):
        mbr = MBR(key[:self.n_dims], key[:self.n_dims])
        return self.search(mbr)

    cpdef LeafEntry insert_datapoint(self, f64[:] key, object value):
        mbr = MBR(key[:self.n_dims], key[:self.n_dims])
        entry = LeafEntry(mbr, value)

        self.insert(entry)
        return entry

    cpdef list root_children(self):
        return self.root.children

    cpdef RNode get_root(self):
        return self.root