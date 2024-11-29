extends Node


# Variables
var g
var graph = {}
var edges = {}
var labels = {}
var distances = {}
var fedges = {}
var fbuttons = {}
var source
var destination
var PriorityQueue = preload("res://PriorityQueue.gd")  # Adjust path if needed
var QLabel
var BLabel
var map = {1: "A", 2: "B", 3:"C", 4:"D", 5:"E", 6:"F", 7:"G", 8:"H", 9:"I"}
var default_texture = load("res://PNGs/platformPack_tile024.png")
var reached_texture = load("res://PNGs/platformPack_tile023.png")

# Step-based animation
var steps = []  # Sequence of saved steps
var current_step = -1  # Start at -1, indicating no steps taken yet
var dijkstra_state = {}  # Store Dijkstra's state across steps
var destination_reached = false  # Flag for destination reach status
var algorithm_completed = false  # Flag to indicate when all nodes are processed

# Entry function to initialize Dijkstra's setup
func _entry():
	reset_dijkstra_state()  # Reset the state for a fresh run
	initialize_fb()
	_save_current_state()  # Save the initial state
	dijkstra_setup()

# Initialize edges and labels, ensure all fedges are hidden and fbuttons inactive
func initialize_fb():
	for label_key in distances.keys():
		var label = distances[label_key]
		var stylebox = StyleBoxTexture.new()
		stylebox.texture = default_texture
		label.add_theme_stylebox_override("normal", stylebox)
		
	# Hide all fedges initially
	for edge in fedges.values():
		_set_fedge_visibility(edge, false)

	# Set all buttons inactive initially
	for button in fbuttons.values():
		if button == null:
			print("Warning: Button Missing")
		else:
			button.disabled = true

	# Hide the SPT button initially
	if fbuttons.has("SPT"):
		fbuttons["SPT"].visible = false
		fbuttons["SPT"].disabled = true

# Reset function to allow multiple runs
func reset_dijkstra_state():
	steps.clear()
	current_step = -1
	destination_reached = false
	algorithm_completed = false
	dijkstra_state.clear()
	clear_label()
	print("Algorithm state reset for a new run.")

# Clear the textures for all distance labels
func clear_label():
	for label_key in distances.keys():
		var label = distances[label_key]
		label.remove_theme_stylebox_override("normal")  # Remove the stylebox override
	
# Initialize edges and labels
func initialize(edges_data, labels_data, distances_data, graph_data, source_node, destination_node, Qlabel, Fbuttons, Fedges, blabel) -> void:
	edges = edges_data
	labels = labels_data
	distances = distances_data
	graph = graph_data
	source = source_node
	destination = destination_node
	QLabel = Qlabel
	fbuttons = Fbuttons
	fedges = Fedges
	BLabel = blabel
	print("Initialized graph: ", graph)

# Setup function for Dijkstra's algorithm
func dijkstra_setup():
	var dist = {}
	var prev = {}
	var pq = PriorityQueue.new()

	for node in graph.keys():
		dist[node] = INF
		prev[node] = null
		_update_distance_label(node, dist[node])
		pq.upsert(node, INF)
		#print("HEAP:", pq.heap)

	dist[source] = 0
	_update_distance_label(source, dist[source])

	pq.upsert(source, 0)  # Insert the source with priority 0
	_update_queue_display(pq)

	dijkstra_state = {
		"dist": dist,
		"prev": prev,
		"pq": pq,
		"current": null
	}

	_save_current_state()
	print("Initial state saved.")

func dijkstra_step():
	if algorithm_completed:
		return false  # Exit if all reachable nodes have been processed

	var dist = dijkstra_state["dist"]
	var prev = dijkstra_state["prev"]
	var pq = dijkstra_state["pq"]

	if pq.is_empty():
		print("Priority queue is empty, finishing trace.")
		algorithm_completed = true
		
		# Show and enable the SPT button when all nodes are processed
		if fbuttons.has("SPT"):
			fbuttons["SPT"].visible = true
			fbuttons["SPT"].disabled = false
		return false

	#print("HEAP IN STEP: ", pq.heap)
	var current_entry = pq.pop()
	var current = current_entry["value"]
	dijkstra_state["current"] = current
	_update_queue_display(pq)

	#print("Processing node: ", current)

	if prev.has(current) and prev[current] != null:
		highlight_edge(prev[current], current, "red")

	if current == destination:
		destination_reached = true
		print("Destination reached, but continuing trace until all nodes are processed.")

	var stylebox = StyleBoxTexture.new()
	stylebox.texture = reached_texture
	distances["TD"+str(current)].add_theme_stylebox_override("normal", stylebox)
	var button_key = "B" + str(current)
	if fbuttons.has(button_key):
		fbuttons[button_key].disabled = false

	for neighbor in graph[current].keys():
		var alt = dist[current] + graph[current][neighbor]
		if alt < dist[neighbor]:
			dist[neighbor] = alt
			prev[neighbor] = current
			#print("Before Upsert: ", pq.heap)
			pq.upsert(neighbor, alt)
			#print("After Upsert: ", pq.heap)
			_update_distance_label(neighbor, dist[neighbor])
			_update_queue_display(pq)

	_save_current_state()
	return true

# Highlight the edge (initial step before final path)
func highlight_edge(from_node, to_node, color):
	var edge_key = str(from_node) + "_" + str(to_node)
	if edges.has(edge_key):
		_set_edge_visibility(edges[edge_key], true)
		_set_edge_color(edges[edge_key], color)
		# Also highlight in fedges for final path
		highlight_final_edge(from_node, to_node)

# Update distance label
func _update_distance_label(node, distance):
	var label_key = "TD" + str(node)
	if distances.has(label_key):
		if str(distance) == "inf":
			distances[label_key].text = "∞"
		else:
			distances[label_key].text = str(distance)

func _update_queue_display(pq):
	var queue_text = "Priority Queue (Sorted by Distance):\n"
	var sorted_heap = pq.heap.duplicate()
	sorted_heap.sort_custom(Callable(self, "_compare_priority"))
	
	var flag = 0
	
	for entry in sorted_heap:
		var dl = "∞" if entry["priority"] == INF else str(entry["priority"])
		var node = map[entry["value"]]
		if flag==0:
			queue_text += "[fill][color=tomato]Node : " + node + " ,  Distance : " + dl + "[/color][/fill]\n"
			flag = 1
		else:
			queue_text += "[fill]Node : " + node + " ,  Distance : " + dl + "[/fill]\n"
	QLabel.text = queue_text

# Custom comparison function for sorting by priority
func _compare_priority(a, b) -> bool:
	return a["priority"] < b["priority"]
	
# Helper function to generate repeated spaces
func repeat_string(character, count):
	var result = ""
	for i in range(count):
		result += character
	return result
	
func _save_current_state():
	if algorithm_completed and (current_step == steps.size() - 1):
		return

	var state = {}
	state.edges = []
	state.distances = []
	state.queue = QLabel.text
	state.button_states = {}  # Track button enabled/disabled state
	state.fedge_visibility = {}  # Track fedge visibility state
	state.spt_button = {}  # Track the SPT button state

	# Save a deep copy of the dijkstra_state to prevent unintended modifications
	state.current_dijkstra_state = dijkstra_state.duplicate(true)

	for edge_key in labels.keys():
		var from_to = edge_key.split("_")
		state.edges.append({
			"from_node": int(from_to[0]),
			"to_node": int(from_to[1]),
			"color": edges[edge_key].modulate
		})

	for label_key in distances.keys():
		var label = distances[label_key]
		var stylebox = label.get_theme_stylebox("normal")  # Retrieve the current StyleBox
		var texture = null
		if stylebox is StyleBoxTexture:
			texture = stylebox.texture  # Get the texture from the StyleBoxTexture
		
		state.distances.append({
			"node": int(label_key.substr(1)),
			"distance": label.text,
			"texture": texture  # Save the texture
		})


	# Save the current button states
	for button_key in fbuttons.keys():
		state.button_states[button_key] = !fbuttons[button_key].disabled

	# Save `fedge` visibility states
	for fedge_key in fedges.keys():
		state.fedge_visibility[fedge_key] = fedges[fedge_key].get_node("Edge").visible

	# Save the SPT button state
	if fbuttons.has("SPT"):
		state.spt_button = {
			"visible": fbuttons["SPT"].visible,
			"disabled": fbuttons["SPT"].disabled
		}

	if current_step == steps.size() - 1:
		steps.append(state)
	else:
		steps[current_step + 1] = state

	current_step += 1
	#print("Saved step ", current_step, " with state: ", state)

func _apply_step(step_index):
	# Reset all edges visibility
	for edge_key in edges.keys():
		_set_edge_visibility(edges[edge_key], false)
		_set_fedge_visibility(fedges[edge_key], false)

	var step = steps[step_index]
	for edge_data in step.edges:
		highlight_edge(edge_data.from_node, edge_data.to_node, edge_data.color)

	for distance_data in step.distances:
		_update_distance_label(distance_data.node, distance_data.distance)
		
		if distance_data.has("texture") and distance_data.texture != null:
			var label = distances["TD" + str(distance_data.node)]
			var stylebox = StyleBoxTexture.new()
			stylebox.texture = distance_data.texture
			label.add_theme_stylebox_override("normal", stylebox)

	QLabel.text = step.queue
	dijkstra_state = step.current_dijkstra_state.duplicate(true)

	for button_key in fbuttons.keys():
		if step.button_states.has(button_key):
			fbuttons[button_key].disabled = !step.button_states[button_key]

	for fedge_key in step.fedge_visibility.keys():
		_set_fedge_visibility(fedges[fedge_key], step.fedge_visibility[fedge_key])

	# Restore the SPT button state
	if fbuttons.has("SPT") and step.spt_button != null:
		fbuttons["SPT"].visible = step.spt_button["visible"]
		fbuttons["SPT"].disabled = step.spt_button["disabled"]

	#print("Applied step ", step_index, " with state: ", step)

# Move to next step
func _next_step():
	if current_step < steps.size() - 1:
		current_step += 1
		_apply_step(current_step)
	else:
		if not algorithm_completed:
			if dijkstra_step():
				print("Processing new step and saved current state")
			else:
				print("Algorithm finished")
		else:
			BLabel.text = "All Nodes Reached."
			
			if fbuttons.has("SPT"):
				fbuttons["SPT"].visible = true
				fbuttons["SPT"].disabled = false
# Move to previous step
func _previous_step():
	if current_step > 0:
		current_step -= 1
		_apply_step(current_step)
		if current_step==0:
			clear_label()
		#print("Moved to previous step:", current_step)
	else:
		print("Already at the first step. Cannot go back further.")

# Input handling
func input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		print("Up arrow key pressed. Moving to next step.")
		_next_step()
	elif event.is_action_pressed("ui_down"):
		print("Down arrow key pressed. Moving to previous step.")
		_previous_step()
		
# Hide or show an edge and its associated label
func _set_edge_visibility(edge, visible):
	if edge is CanvasItem:
		edge.visible = visible
	for child in edge.get_children():
		if child is CanvasItem:
			child.visible = visible

# Special hide or show for `fedges` edges
func _set_fedge_visibility(fedge, visible):
	if fedge.has_node("Edge") and fedge.has_node("ELabel"):
		fedge.get_node("Edge").visible = visible
		fedge.get_node("ELabel").visible = visible

# Set edge color
func _set_edge_color(edge, color):
	if edge is CanvasItem:
		edge.modulate = color

# Highlight final edge path in fedges with green color
func highlight_final_edge(from_node, to_node):
	var edge_key = str(from_node) + "_" + str(to_node)
	if fedges.has(edge_key):
		# Set the visibility and color of both Edge and ELabel children to green
		var edge_node = fedges[edge_key].get_node("Edge")
		var label_node = fedges[edge_key].get_node("ELabel")
		
		if edge_node and label_node:
			_set_fedge_visibility(fedges[edge_key], true)  # Make fedges visible
			edge_node.modulate = Color(0, 1, 0)  # Set Edge color to green
			label_node.modulate = Color(0, 1, 0)  # Set ELabel color to green

# Display the Shortest Path Tree (SPT) using fedges based on the predecessor information
func display_spt():
	var prev = dijkstra_state["prev"]

	# Iterate through the predecessor map to highlight the SPT edges
	for node in prev.keys():
		var parent = prev[node]
		if parent == null:
			continue  # Skip nodes with no predecessor

		# Construct the edge key based on the parent-child relationship
		var edge_key = str(parent) + "_" + str(node)
		if not fedges.has(edge_key):
			print("Warning: Edge key not found in fedges: ", edge_key)
			continue

		# Get the edge and label nodes
		var edge_node = fedges[edge_key].get_node("Edge")
		var label_node = fedges[edge_key].get_node("ELabel")

		# Highlight the edge and label in green for the SPT
		if edge_node and label_node:
			_set_fedge_visibility(fedges[edge_key], true)
			edge_node.modulate = Color(0, 1, 0)  # Set Edge color to green
			label_node.modulate = Color(0, 1, 0)  # Set ELabel color to green

	print("Displayed the Shortest Path Tree using highlighted edges only.")
