# The R-Tree Algorithm

### Sturctures (classes)
* MBR
* RNode (node, leafnode)
* RTree

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

### RNode
```python

```