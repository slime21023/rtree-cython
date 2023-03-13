# The R-Tree Algorithm

### Structure (Classes)

- MBR
- LeafEntry
- RNode (node, leafnode)
- RTree

### MBR

```python
class MBR
    def __init__(self, mins: np.ndarray, maxs: np.ndarray)
        self.mins = mins
        self.maxs = maxs

    def is_overlapping(self, o: MBR) -> bool:
        dim: int = 0
        result: bool = True
        condition_one: bool = True
        condition_two: bool = True

        for dim in range(self.mins.shape[0]):
			condition_one = self.mins[dim] >= o.mins[dim] and self.mins[dim] <= o.maxs[dim]
            condition_two = self.maxs[dim] >= o.mins[dim] and self.maxs[dim] <= o.maxs[dim]
            if not (condition_one or condition_two):
                result = False
                break
        return result

    def enlarge(self, r: MBR):
        dim: int = 0
        for dim in range(self.mins.shape[0]):
            if r.mins[dim] < self.mins[dim]:
                self.mins[dim] = r.mins[dim] - 25.0
            if r.maxs[dim] > self.maxs[dim]:
                self.maxs[dim] = r.maxs[dim] + 25.0
    
    def volume(self) -> float:
        v: float = 1
        dim: int = 0
        for dim in range(self.mins.shape[0]):
            v *= (self.maxs[dim] - self.mins[dim])

        return v

    def overlapped_volume(self, r: MBR) -> float:
        v: float = 1
        dim: int = 0
        cur_min: float = 0
        cur_max: float = 0
        if not self.is_overlapping(r):
            return 0
        else:
            for dim in range(self.mins.shape[0]):
                cur_min = self.mins[dim] if self.mins[dim] > r.mins[dim] else r.mins[dim]
                cur_max = self.maxs[dim] if self.maxs[dim] < r.maxs[dim] else r.maxs[dim]
                v *= (cur_max - cur_min)
        return v

    def is_cover(self, r: MBR) -> bool:
        dim: int = 0
        result: bool = True
        for dim in range(self.mins.shape[0]):
            if not ((self.mins[dim] <= r.mins[dim]) and (self.maxs[dim] >= r.maxs[dim])):
                result = False
                break
        return result

    def distance(self, r: MBR) -> float
        d: float = 0
        dim: int = 0
        temp1: float = 0
        temp2: float = 0
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
```

### LeafEntry

```python
class LeafEntry:
	def __init__(self, mbr: MBR, item: object):
		self.mbr = mbr
		self.item = item

	def is_same(self, o: LeafEntry):
		dim: int = 0
		same: bool = True

		for dim in range(self.mbr.mins.shape[0]):
			if o.mbr.mins[dim] != self.mbr.mins[dim]:
				same = False
				break
			if o.mbr.maxs[dim] != self.mbr.maxs[dim]:
				same = False
				break
		return same
```

### RNode

```python
class RNode:
	def __init__(self, mbr: MBR, is_leaf:bool = True):
		self.is_leaf = is_leaf
		self.mbr = mbr
		if not is_leaf:
			self.children = []
		else:
			self.items = []

	def search(self, q: MBR) -> list:
		idx: int = 0
		result: list = []
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

	def choose_leaf(self, q: MBR) -> RNode:
		idx: int = 0
		selected: int = -1
		temp: float = 0
		calc: float = 0

		if self.is_leaf:
			return self
		else:
			for idx in range(len(self.children)):
				calc = self.children[idx].overlapped_volume(q)
				if calc > temp:
					temp = calc
					selected = idx

			if selected == -1:
				idx = 0
				calc = 0
				temp = 0
				for idx in range(len(self.children)):
					calc = self.children[idx].distance(q)
					if idx == 0;
						temp = calc
						selected = idx

					if calc < temp:
						temp = calc
						selected = idx

			self.children[selected].mbr.enlarge(q)
			return self.children[selected].choose_leaf(q)
	
	def pick_seeds(self) -> tuple:
		idx: int = 0
		seeds: list = []
		is_overlapping: bool = True
		seed_one: int = -1
		seed_two: int = -1
		calc: int = 0
		temp: int = 0
		
		if sefl.is_leaf:
			seeds += self.items
		else:
			seeds	+= self.children

		# check is all overlapping	
		for idx in range(1, len(seeds)):
			if not seeds[0].mbr.is_overlapping(seeds[idx]):
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
			for idx in range(len(seeds) -1):
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

	def split_leaf(self):
		idx: int = 0
		is_overlapping_with_g1: bool = False
		is_overlapping_with_g2: bool = False

		if not self.is_leaf:
			return
		
		s1, s2 = self.pick_seeds()
		
		# create two leaf node
		e1 = self.items.pop(s1)
		e2 = self.items.pop(s2 - 1)
		
		g1 = RNode(e1.mbr, is_leaf=True)
		g1.items.append(e1)
		
		g2 = RNode(e2.mbr, is_leaf=True)
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
	

	def split_node(self, parent: RNode):
		idx: int = 0
		is_overlapping_with_g1: bool = False
		is_overlapping_with_g2: bool = False
		is_root: bool = (self == parent)

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
			is_overlapping_with_g1 = item.mbr.is_overlapping(g1.mbr)
			is_overlapping_with_g2 = item.mbr.is_overlapping(g2.mbr)

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
				g2.children.append(ichildem)
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
			

	def adjust_tree(self, parent: RNode, max_size: int):
		idx: int = 0
		temp: list = []
		has_leaf: bool = False
		has_node: bool = False		

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
			for idx in range(temp):
				self.children.remove(temp[idx])
			parent.childern += temp
		
		# check the size of children
		if len(self.children) > max_size:
			self.split_node(parent)

	
	def insert(self, item: LeafEntry, max_size: int):
		leaf: RNode
		
		leaf = self.choose_leaf(item.mbr)
		leaf.items.append(item)

		if len(leaf.items) > max_size:
			leaf.split_leaf()
		
		self.adjust_tree(self, max_size)


	def find_leaf(self, mbr: MBR) -> list[RNode]:
		idx: int = 0
		result: list = []

		if self.mbr.is_cover(mbr) and self.is_leaf:
			result.append(self)
			return result
		
		if self.mbr.is_cover(mbr) and not self.is_leaf:
			for idx in range(len(self.children)):
				result += self.children[idx].find_leaf(mbr)
		
		return result

	def remove_leaf(self, leaf: RNode):
		idx: int = 0
		is_contain: bool = False
		if self.is_leaf:
			return
		
		for idx in range(len(self.children)):
			if self.children[idx].mbr.is_cover(leaf.mbr):
				self.children[idx].remove(leaf)

			if self.children[idx] == leaf:
				is_contain = True
		
		self.children.remove(leaf)

	def remove_entry(self, entry: LeafEntry) -> bool:
		idx: int = 0
		selected: int = -1

		if not self.is_leaf:
			return
		
		for idx in range(len(self.items)):
			if self.items[idx].is_same(entry):
				selected = idx
				break
		if selected != -1:
			self.items.pop(selected)
			return True
		else:
			return False

	def condense_tree(self, leaf: RNode, min_size: int, max_size: int):
		temp: list = []
		idx: int = 0		

		if not leaf.is_leaf:
			return
		
		if len(leaf.items) < min_size:
			temp += leaf.items

		self.remove_leaf(leaf)

		for idx in range(len(temp)):
			self.insert(temp[idx], max_size)

	def delete(self, entry: LeafEntry, min_size: int, max_size: int):
		temp: list = []
		idx: int = 0
		leaf: RNode = None
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
```

### RTree

```python
class RTree:
	def __init__(self, min_children: int, max_children: int):
		self.min_children = min_children
		self.max_children = max_children
		self.root = None
	
	def insert(self, entry: LeafEntry):
		if self.root == None:
			self.root = RNode(entry.mbr)
		
		self.root.insert(entry, self.max_children)
	
	def search(self, mbr: MBR) -> list:
		if self.root == None:
			return []
		
		self.root.search(mbr)

	def delete(self, entry: LeafEntry):
		if self.root == None:
			return
		self.root.delete(entry, self.min_children, self.max_children)

	def insert_datapoint(self, key, value) -> LeafEntry:
		mbr = MBR(key, key)
		entry = LeafEntry(mbr, value)
		
		self.insert(entry)
		return entry
	
	def search_datapoint(self, key) -> list:
		mbr = MBR(key, key)
		return self.search(mbr)
```
