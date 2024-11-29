extends Resource

class_name OptimizedPriorityQueue

var heap = []
var indices = {}  # Store indices for fast look-up

# Add or update an element in the priority queue
func upsert(value, priority):
	var index = indices.get(value, -1)
	if index == -1:
		# Value not in the queue, add it
		heap.append({"value": value, "priority": priority})
		index = heap.size() - 1
		indices[value] = index
		_heapify_up(index)
	else:
		# Update existing entry
		var old_priority = heap[index]["priority"]
		heap[index]["priority"] = priority
		if priority < old_priority:
			_heapify_up(index)
		else:
			_heapify_down(index)

# Pop the element with the minimum priority
func pop():
	if is_empty():
		return null

	var min_elem = heap[0]  # Save the min element (root)
	indices.erase(min_elem["value"])  # Remove it from indices

	var last_elem = heap.pop_back()  # Get the last element
	if not is_empty():
		heap[0] = last_elem  # Move last element to root
		indices[last_elem["value"]] = 0  # Update its index
		_heapify_down(0)  # Restore heap property

	return min_elem

# Check if the queue is empty
func is_empty() -> bool:
	return heap.size() == 0

# Restore the heap property upwards
func _heapify_up(index):
	while index > 0:
		var parent_index = (index - 1) / 2
		if heap[index]["priority"] < heap[parent_index]["priority"]:
			_swap(index, parent_index)
			index = parent_index
		else:
			break

# Restore the heap property downwards
func _heapify_down(index):
	var size = heap.size()
	while true:
		var left_child_index = index * 2 + 1
		var right_child_index = index * 2 + 2
		var smallest_index = index

		if left_child_index < size and heap[left_child_index]["priority"] < heap[smallest_index]["priority"]:
			smallest_index = left_child_index
		if right_child_index < size and heap[right_child_index]["priority"] < heap[smallest_index]["priority"]:
			smallest_index = right_child_index

		if smallest_index == index:
			break  # Heap property restored

		_swap(index, smallest_index)
		index = smallest_index

# Swap two elements in the heap
func _swap(i, j):
	var temp = heap[i]
	heap[i] = heap[j]
	heap[j] = temp

	# Update indices
	indices[heap[i]["value"]] = i
	indices[heap[j]["value"]] = j
