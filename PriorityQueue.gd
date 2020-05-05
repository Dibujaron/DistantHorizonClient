extends Node

# Priority Queue implementation with binary heap
# the score_comparison_func must take two args stored in the heap and return a comparison # (like java comparable).
# based on one by rileyphone from https://godotengine.org/qa/12915/priority-queue
var heaplist
var currentSize
var score_comparison_func
var equal_position_func

func _init(score_comparison_func, equal_position_func):
	heaplist = [[0]]
	currentSize = 0
	self.score_comparison_func = score_comparison_func
	self.equal_position_func = equal_position_func
	
func percUp(i):
	while floor(i / 2) > 0:
		#if heaplist[i][0] < heaplist[floor(i / 2)][0]:
		if score_comparison_func.call_func(heaplist[i][0], heaplist[floor(i/2)][0]) < 0:
			var tmp = heaplist[floor(i / 2)]
			heaplist[floor(i / 2)] = heaplist[i]
			heaplist[i] = tmp
		i = floor(i / 2)

func insert(k):
	heaplist.append(k)
	currentSize += 1
	percUp(currentSize)

func percDown(i):
	while (i * 2) <= currentSize:
		var mc = minChild(i)
		#if heaplist[i][0] > heaplist[mc][0]:
		if score_comparison_func.call_func(heaplist[i][0], heaplist[mc][0]) > 0:
			var tmp = heaplist[i]
			heaplist[i] = heaplist[mc]
			heaplist[mc] = tmp
		i = mc

func minChild(i):
	if i * 2 + 1 > currentSize:
		return i * 2
	else:
		#if heaplist[i*2][0] < heaplist[i*2+1][0]:
		if score_comparison_func.call_func(heaplist[i*2][0], heaplist[i*2+1][0]) < 0:
			return i * 2
		else:
			return i * 2 + 1

func pop():
	var retval = heaplist[1]
	heaplist[1] = heaplist[currentSize]
	heaplist.remove(currentSize - 1)
	currentSize -= 1
	percDown(1)
	return retval

#this can certainly be more efficient
func contains_equivalent_with_lower_score(test_item):
	for column in heaplist
		for heap_item in column:
			if equal_position_func.call_func(heap_item, test_item):
				if score_comparison_func.call_func(heap_item, test_item) < 0
					return true
	return false
	
func empty():
	return currentSize < 1
