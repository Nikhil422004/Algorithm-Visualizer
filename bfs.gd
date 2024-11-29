extends Node

var g
var graph = {}
var edges
var labels
var timers
var BLabel
var edges_divided = {}
var reached_nodes = {}
var predecessors = {}
var distances = {}
var final_path = []
var edge_permissions = {}
var edge_segment_indices = {}
var original_edge_points = {}
var state_stack = []
var current_state_index = -1
var remaining_time_steps = {}
var fedges
var fbuttons
var highlighted_fedges = []  # List to store all highlighted fedges

var dijkstras = preload("res://dijkstras.gd")
var default_texture = load("res://PNGs/platformPack_tile011.png")
var reached_texture = load("res://PNGs/platformPack_tile023.png")

var source_node 
var destination_node 
var all_nodes_reached = false
var destination_reached = false  # Flag to check if the destination has been reached
var path_dist = {}  # Dictionary to store shortest reach time to each node
var time_counter  # Global counter for timesteps

func _entry():
	time_counter = -2
	_capture_state()
	initialize_fb()
	_initialize_graph()
	_capture_state()

func initialize_fb():
	for label_key in timers.keys():
		var label = timers[label_key]
		var stylebox = StyleBoxTexture.new()
		if label_key=="TD"+str(source_node):
			stylebox.texture = reached_texture
		else:
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
	
	fbuttons["B"+str(source_node)].disabled = false

func initialize(edges_data, labels_data, timers_data, graph_data, source, destination, Fedges, Fbuttons, blabel) -> void:
	edges = edges_data
	labels = labels_data
	timers = timers_data
	graph = graph_data
	source_node = source
	destination_node = destination
	fedges = Fedges
	fbuttons = Fbuttons
	BLabel = blabel
	print("Initialized graph: ", graph)

func _initialize_graph(): 
	for node in graph.keys():
		distances[node] = INF
		predecessors[node] = null
		timers["TD"+str(node)].text = "∞"
		remaining_time_steps[node] = INF
		path_dist[node] = INF  # Initialize path_dist for each node as infinity

	distances[source_node] = 0
	remaining_time_steps[source_node] = 0
	timers["TD"+str(source_node)].text = "0"
	path_dist[source_node] = 0  # Source node distance is 0 in path_dist as well

	for edge_key in edges.keys():
		var weight = int(labels[edge_key].text)
		original_edge_points[edge_key] = edges[edge_key].points.duplicate()
		edges_divided[edge_key] = _divide_edge(edges[edge_key], weight)
		edge_segment_indices[edge_key] = 0

	for neighbor in graph[source_node].keys():
		var edge_key = str(source_node) + "_" + str(neighbor)
		edge_permissions[edge_key] = true
		timers["TD"+str(neighbor)].text = labels[edge_key].text

	_capture_state()

func _divide_edge(edge: Line2D, weight: int) -> Array:
	var points = edge.points
	var start_point = points[4]
	var end_point = points[1]
	var segments = []

	for i in range(weight):
		var t = float(i) / float(weight)
		segments.append(start_point.lerp(end_point, t))

	segments.append(end_point)
	return segments

func _capture_state():
	time_counter += 1

	if all_nodes_reached:
		return

	var state = {
		'edges': {},
		'reached_nodes': reached_nodes.duplicate(),
		'timers': {},
		'edge_permissions': edge_permissions.duplicate(),
		'edge_segment_indices': edge_segment_indices.duplicate(),
		'remaining_time_steps': remaining_time_steps.duplicate(),
		'all_nodes_reached': all_nodes_reached,
		'dots': {},
		'fedges': {},  # Store fedges state
		'fbuttons': {}  # Store fbuttons state
	}

	for edge_key in edges.keys():
		state['edges'][edge_key] = {
			'points': edges[edge_key].points.duplicate(),
			'color': edges[edge_key].default_color,
		}
		state['dots'][edge_key] = []
		for dot in edges[edge_key].get_children():
			if dot is Node2D:
				state['dots'][edge_key].append(dot.position)

	for timer_key in timers.keys():
		var timer_label = timers[timer_key]
		var stylebox = timer_label.get_theme_stylebox("normal")
		var texture = null
		if stylebox is StyleBoxTexture:
			texture = stylebox.texture  # Extract the texture if it exists

		state['timers'][timer_key] = {
			'text': timer_label.text,
			'texture': texture  # Save the texture
		}

	# Store the visibility and color state of fedges
	for fedge_key in fedges.keys():
		var fedge = fedges[fedge_key]
		state['fedges'][fedge_key] = {
			'visible': fedge.get_node("Edge").visible,
			'edge_color': fedge.get_node("Edge").modulate,
			'label_color': fedge.get_node("ELabel").modulate
		}

	# Store the enabled/disabled state of fbuttons
	for button_key in fbuttons.keys():
		state['fbuttons'][button_key] = {
			'visible': fbuttons[button_key].visible,
			'disabled': fbuttons[button_key].disabled
		}

	if current_state_index < state_stack.size() - 1:
		state_stack.resize(current_state_index + 1)
	state_stack.append(state)
	current_state_index += 1

	print("Captured state. Current stack size: ", state_stack.size())
	print("Current state index: ", current_state_index)


func _restore_state(state):
	print("Restoring state at index: ", current_state_index)

	for edge_key in state['edges'].keys():
		var edge = edges[edge_key]
		edge.clear_points()
		for point in state['edges'][edge_key]['points']:
			edge.add_point(point)
		edge.default_color = state['edges'][edge_key]['color']

		for dot in edge.get_children():
			if dot is Node2D:
				dot.queue_free()

		for dot_position in state['dots'][edge_key]:
			var dot = _create_dot(dot_position)
			edge.add_child(dot)

	reached_nodes = state['reached_nodes'].duplicate()
	edge_permissions = state['edge_permissions'].duplicate()
	edge_segment_indices = state['edge_segment_indices'].duplicate()
	remaining_time_steps = state['remaining_time_steps'].duplicate()
	all_nodes_reached = state['all_nodes_reached']

	for timer_key in state['timers'].keys():
		var timer_label = timers[timer_key]
		var timer_state = state['timers'][timer_key]

		# Restore timer text
		timer_label.text = timer_state['text']

		# Restore timer texture
		if timer_state.has("texture") and timer_state['texture'] != null:
			var stylebox = StyleBoxTexture.new()
			stylebox.texture = timer_state['texture']
			timer_label.add_theme_stylebox_override("normal", stylebox)
		else:
			# Clear the texture if none was saved
			timer_label.remove_theme_stylebox_override("normal")

	# Restore fedges visibility and colors
	for fedge_key in state['fedges'].keys():
		if fedges.has(fedge_key):
			var fedge_state = state['fedges'][fedge_key]
			var fedge = fedges[fedge_key]
			_set_fedge_visibility(fedge, fedge_state['visible'])
			fedge.get_node("Edge").modulate = fedge_state['edge_color']
			fedge.get_node("ELabel").modulate = fedge_state['label_color']

	# Restore fbuttons visibility and enabled state
	for button_key in state['fbuttons'].keys():
		if fbuttons.has(button_key):
			var button_state = state['fbuttons'][button_key]
			fbuttons[button_key].visible = button_state['visible']
			fbuttons[button_key].disabled = button_state['disabled']

	print("State restored.")

func _draw_segment_dots(edge: Line2D, segment_points: Array):
	for i in range(1, len(segment_points)-1):  # Start from index 1 to skip the first point
		var point = segment_points[i]
		var dot = _create_dot(point)
		edge.add_child(dot)


func _create_dot(position: Vector2) -> Node2D:
	var dot = Node2D.new()
	dot.position = position

	var circle = ColorRect.new()
	circle.color = Color.AQUA
	circle.size = Vector2(120, 120)  # Adjust size as needed
	circle.position = Vector2(-50, 0)  # Center the dot
	dot.add_child(circle)

	return dot


func _highlight_edge_segment(edge: Line2D, segment_points: Array, index: int, color: Color):
	if index < len(segment_points):
		edge.default_color = color
		edge.clear_points()
		for i in range(index + 1):
			edge.add_point(segment_points[i])
			edge.add_point(segment_points[i + 1])
		_draw_segment_dots(edge, segment_points)  # Draw dots for the segments

func _visualize():
	if all_nodes_reached:
		BLabel.text = "All Nodes Reached"
		return

	var animations_active = false

	for edge_key in edge_permissions.keys():
		if edge_permissions[edge_key]:
			var start_node = _parse_edge_key(edge_key)[0]
			var end_node = _parse_edge_key(edge_key)[1]
			if reached_nodes.has(end_node):
				continue

			var segments = edges_divided[edge_key]
			var segment_index = edge_segment_indices[edge_key]

			if segment_index < segments.size() - 1:
				_highlight_edge_segment(edges[edge_key], segments, segment_index, Color.AQUA)
				animations_active = true
				edge_segment_indices[edge_key] += 1

			if segment_index == segments.size() - 2:
				reached_nodes[end_node] = true
				edge_permissions[edge_key] = false
				predecessors[end_node] = start_node
				_highlight_full_edge(edge_key, Color.AQUA)
				highlight_final_edge(start_node, end_node)
				_grant_permissions_for_outgoing_edges(end_node)

				# Set path_dist for the end_node when reached
				if path_dist[end_node] == INF:
					path_dist[end_node] = time_counter  # Set the timestep at which this node is reached
				
				var stylebox = StyleBoxTexture.new()
				stylebox.texture = reached_texture
				timers["TD"+str(end_node)].add_theme_stylebox_override("normal", stylebox)
				var button_key = "B" + str(end_node)
				if fbuttons.has(button_key):
					fbuttons[button_key].disabled = false

				if end_node == destination_node:
					destination_reached = true

			_update_timer(end_node, segment_index, segments.size() - 1)

	if destination_reached and !animations_active:
		all_nodes_reached = true
		if fbuttons.has("SPT"):
			var spt_button = fbuttons["SPT"]
			spt_button.visible = true
			spt_button.disabled = false
			BLabel.text = "All Nodes Reached"
			print("SPT button is now active and visible.")
			
	_capture_state()
	
func _grant_permissions_for_outgoing_edges(node: int):
	for neighbor in graph[node].keys():
		var edge_key = str(node) + "_" + str(neighbor)
		if !edge_permissions.has(edge_key):
			edge_permissions[edge_key] = true
			edge_segment_indices[edge_key] = 0

			var total_segments = edges_divided[edge_key].size() - 1
			remaining_time_steps[neighbor] = min(remaining_time_steps[neighbor], total_segments)
			timers["TD"+str(neighbor)].text = str(remaining_time_steps[neighbor])

func _highlight_full_edge(edge_key: String, color: Color):
	var edge = edges[edge_key]
	edge.default_color = color
	edge.clear_points()
	for point in original_edge_points[edge_key]:
		edge.add_point(point)

func _update_timer(node: int, current_segment_index: int, total_segments: int):
	var remaining_steps = total_segments - current_segment_index - 1
	remaining_time_steps[node] = min(remaining_time_steps[node], remaining_steps)
	timers["TD"+str(node)].text = str(remaining_time_steps[node])

	print("Updated timer for node ", node, ": ", timers["TD"+str(node)].text)

func _parse_edge_key(edge_key: String) -> Array:
	var parts = edge_key.split("_")
	return [int(parts[0]), int(parts[1])]

func input(event: InputEvent):
	if event.is_action_pressed("ui_right"):
		if current_state_index < state_stack.size() - 1:
			current_state_index += 1
			_restore_state(state_stack[current_state_index])
		else:
			_visualize()

	elif event.is_action_pressed("ui_left"):
		if current_state_index > 0:
			current_state_index -= 1
			_restore_state(state_stack[current_state_index])
		else:
			print("Already at the initial state, cannot go back further.")

# Special hide or show for `fedges` edges
func _set_fedge_visibility(fedge, visible):
	if fedge.has_node("Edge") and fedge.has_node("ELabel"):
		fedge.get_node("Edge").visible = visible
		fedge.get_node("ELabel").visible = visible
		
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
			
			# Store the highlighted fedge
			highlighted_fedges.append(fedges[edge_key])
			print("Highlighted and stored fedge: ", edge_key)

func display_spt():
	print("Displaying all highlighted fedges as part of the SPT.")
	for fedge in highlighted_fedges:
		if fedge.has_node("Edge") and fedge.has_node("ELabel"):
			_set_fedge_visibility(fedge, true)
			fedge.get_node("Edge").modulate = Color(0, 1, 0)  # Set Edge color to green
			fedge.get_node("ELabel").modulate = Color(0, 1, 0)  # Set ELabel color to green
	print("Displayed all highlighted fedges.")
