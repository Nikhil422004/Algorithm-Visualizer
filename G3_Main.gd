extends Node

var source_node = 1
var destination_node = 5
var edges
var labels
var TDlabel
var Textbox
var Header
var BLabel
var fedges
var fbuttons
var Instr
var dot
var graph = {}

var bfs
var dijkstras

enum AlgorithmState {
	INITIAL,
	DIJKSTRA,
	BFS
}

var map = {1: "A", 2: "B", 3:"C", 4:"D", 5:"E",}

var current_state = AlgorithmState.INITIAL
var dijkstra_step_index = 0
var bfs_step_index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_data()
	init()
	set_text(current_state)
	
func init():
	_create_graph()
	_initialize_bfs()
	_initialize_dijkstras()
		

# Initialize graph and UI-related variables
func _initialize_data():
	edges = {
		"1_4": $Graph3/Edges/E1/Edge1,
		"1_5": $Graph3/Edges/E2/Edge2,
		"2_1": $Graph3/Edges/E3/Edge3,
		"2_3": $Graph3/Edges/E4/Edge4,
		"2_4": $Graph3/Edges/E5/Edge5,
		"3_1": $Graph3/Edges/E6/Edge6,
		"4_5": $Graph3/Edges/E7/Edge7,
		"5_3": $Graph3/Edges/E8/Edge8,
		"5_2": $Graph3/Edges/E9/Edge9,
		"4_3": $Graph3/Edges/E10/Edge10,
	}

	labels = {
		"1_4": $Graph3/Edges/E1/ELabel1,
		"1_5": $Graph3/Edges/E2/ELabel2,
		"2_1": $Graph3/Edges/E3/ELabel3,
		"2_3": $Graph3/Edges/E4/ELabel4,
		"2_4": $Graph3/Edges/E5/ELabel5,
		"3_1": $Graph3/Edges/E6/ELabel6,
		"4_5": $Graph3/Edges/E7/ELabel7,
		"5_3": $Graph3/Edges/E8/ELabel8,
		"5_2": $Graph3/Edges/E9/ELabel9,
		"4_3": $Graph3/Edges/E10/ELabel10,
	}

	TDlabel = {
		"TD1": $Graph3/Nodes/A/TDlabelA,
		"TD2": $Graph3/Nodes/B/TDlabelB,
		"TD3": $Graph3/Nodes/C/TDlabelC,
		"TD4": $Graph3/Nodes/D/TDlabelD,
		"TD5": $Graph3/Nodes/E/TDlabelE,
	}
	
	fedges = {
		"1_4": $"Graph3 Viz/Edges/E1",
		"1_5": $"Graph3 Viz/Edges/E2",
		"2_1": $"Graph3 Viz/Edges/E3",
		"2_3": $"Graph3 Viz/Edges/E4",
		"2_4": $"Graph3 Viz/Edges/E5",
		"3_1": $"Graph3 Viz/Edges/E6",
		"4_5": $"Graph3 Viz/Edges/E7",
		"5_3": $"Graph3 Viz/Edges/E8",
		"5_2": $"Graph3 Viz/Edges/E9",
		"4_3": $"Graph3 Viz/Edges/E10",
	}

	fbuttons = {
		"B1": $"Graph3 Viz/Button/BA",
		"B2": $"Graph3 Viz/Button/BB",
		"B3": $"Graph3 Viz/Button/BC",
		"B4": $"Graph3 Viz/Button/BD",
		"B5": $"Graph3 Viz/Button/BE",
		"SPT": $"Graph3 Viz/Button/SPT",
	}
	
	convert_object_to_lineedit(labels)

	
	Header = $Graph3/Header
	Instr = $Graph3/Instr
	Textbox = $Graph3/Textbox
	BLabel = $"Graph3 Viz/Button/Label"
	
func convert_object_to_lineedit(obj: Dictionary):
	for key in obj.keys():
		var node = obj[key]
		if node is Label:
			var line_edit = LineEdit.new()
			line_edit.text = node.text
			line_edit.editable = true
			
			# Set position
			line_edit.global_position = node.global_position

			# Set the size to a square
			var square_size = 35  # Adjust the size of the square as needed
			line_edit.custom_minimum_size = Vector2(square_size, square_size)

			# Override minimum character width to 0
			line_edit.add_theme_constant_override("minimum_character_width", 0)

			# Set alignment to center
			line_edit.alignment = 1

			var parent = node.get_parent()
			parent.add_child(line_edit)
			obj[key] = line_edit
			parent.remove_child(node)
			node.queue_free()

func convert_object_to_label(obj: Dictionary):
	for key in obj.keys():
		var node = obj[key]
		if node is LineEdit:
			var label = Label.new()
			label.text = node.text
			
			# Set position and size
			label.global_position = node.global_position
			
			var square_size = 35  # Adjust the size of the square as needed
			label.custom_minimum_size = Vector2(square_size, square_size)
			label.vertical_alignment = 1
			label.horizontal_alignment = 1
			
			var parent = node.get_parent()
			parent.add_child(label)
			obj[key] = label
			parent.remove_child(node)
			node.queue_free()
	
# Dynamically initialize graph from edges and labels
func _create_graph():
	graph.clear()  # Clear the graph for re-initialization

	for edge_key in edges.keys():
		var node_pair = edge_key.split("_")
		var from_node = int(node_pair[0])
		var to_node = int(node_pair[1])
		
		# Ensure both from_node and to_node are present in the graph
		if not graph.has(from_node):
			graph[from_node] = {}
		if not graph.has(to_node):
			graph[to_node] = {}
		
		# Get the weight from the label and add it to the graph
		var weight = int(labels[edge_key].text)
		graph[from_node][to_node] = weight

	# Debug: Print the graph structure for verification
	print("Initialized graph: ", graph)

func _initialize_bfs():
	bfs = preload("res://bfs.gd").new() 
	bfs.initialize(edges, labels, TDlabel, graph, source_node, destination_node, fedges, fbuttons, BLabel)
	add_child(bfs)   

func _initialize_dijkstras():
	dijkstras = preload("res://dijkstras.gd").new()  
	dijkstras.initialize(edges, labels, TDlabel, graph, source_node, destination_node, Textbox, fbuttons, fedges, BLabel)
	add_child(dijkstras) 

func set_text(state):
	if state == AlgorithmState.INITIAL:
		Header.text = ""
		Instr.text = "Press Up Arrow for Dijkstras Algorithm.\n Press Right Arrow for Extended BFS Algorithm"
		
	else:
		if state == AlgorithmState.DIJKSTRA:
			Header.text = "dijkstras algorithm"
			if dijkstras.current_step == 0:
				Instr.text = "Reched Initial State. Press Up Arrow for going forward and Down Arrow for going back.\n"
			else:
				Instr.text = "Press Up Arrow for going forward and Down Arrow for going back.\n"
		if state == AlgorithmState.BFS:
			Header.text = "extended bfs algorithm"
			if bfs.current_state_index == 0:
				Instr.text = "Reched Initial State. Press Right Arrow for going forward and Left Arrow for going back.\n"
			else:
				Instr.text = "Press Right Arrow for going forward and Left Arrow for going back.\n"
				
# Input handling
func _input(event):
	set_text(current_state)
	if event.is_action_pressed("ui_up"):
		_clear_all_highlights()
		# Pass execution to Dijkstra's algorithm
		if current_state == AlgorithmState.INITIAL:
			current_state = AlgorithmState.DIJKSTRA
			convert_object_to_label(labels)
			init()
			dijkstras._entry()
		elif current_state == AlgorithmState.DIJKSTRA:
			dijkstras.input(event)
	elif event.is_action_pressed("ui_down"):
		_clear_all_highlights()
		if current_state == AlgorithmState.DIJKSTRA:
			if dijkstras.current_step == 0:
				convert_object_to_lineedit(labels)
				current_state = AlgorithmState.INITIAL
			else:
				dijkstras.input(event)

	elif event.is_action_pressed("ui_right"):
		# Pass execution to BFS algorithm
		_clear_all_highlights()
		if current_state == AlgorithmState.INITIAL:
			convert_object_to_label(labels)
			init()
			current_state = AlgorithmState.BFS
			bfs._entry()
		elif current_state == AlgorithmState.BFS:
			bfs.input(event)
	
	elif event.is_action_pressed("ui_left"):
		_clear_all_highlights()
		if current_state == AlgorithmState.BFS:
			if bfs.current_state_index == 0:
				convert_object_to_lineedit(labels)
				current_state = AlgorithmState.INITIAL
			else:
				bfs.input(event)
	
		
# Handle fbutton press to highlight the shortest path to the node
func _on_button_pressed(node):
	if current_state == AlgorithmState.DIJKSTRA:
	# Ensure `dijkstra_state` is updated and non-empty before calling the highlight function
		if dijkstras.dijkstra_state == {}:
			print("Warning: Dijkstra's state empty on button press. Restoring state...")
		else:
			if node == 0:
				BLabel.text = "All Nodes Reached."
				dijkstras.display_spt()
			else:
				highlight_shortest_path_to_dijkstras(node)
				print("Highlighted shortest path to node", node)
	else:
		if node == 0:
			BLabel.text = "All Nodes Reached."
			bfs.display_spt()
		else:
			highlight_shortest_path_to_bfs(node)
			print("Highlighted shortest path to node", node)
		
# Clear all edge highlights to a default state
func _clear_all_highlights():
	for edge_key in fedges.keys():
		dijkstras._set_edge_visibility(fedges[edge_key], false)  # Hide all edges or reset to default
		dijkstras._set_edge_color(fedges[edge_key], Color(1, 1, 1))  # Reset to white or default color
	
	BLabel.text = "Reached Nodes. Click to see shortest path."
	
# Highlight the final edge using fedges
func highlight_final_edge(from_node, to_node, color):
	var edge_key = str(from_node) + "_" + str(to_node)
	if fedges.has(edge_key):
		dijkstras._set_edge_visibility(fedges[edge_key], true)
		dijkstras._set_edge_color(fedges[edge_key], color)
	
		
# Highlight the path from the source to a destination node in green (final step using fedges)
func highlight_shortest_path_to_dijkstras(node):
	# Ensure dijkstra_state is correctly loaded before highlighting
	_clear_all_highlights()
	if dijkstras.dijkstra_state == {}:
		print("Warning: Dijkstra's state is empty, unable to highlight path.")
		return

	var prev = dijkstras.dijkstra_state["prev"]
	var current = node
	while current != null and current != dijkstras.source:
		var from_node = prev[current]
		if from_node != null:
			highlight_final_edge(from_node, current, "GREEN")
		current = from_node

	BLabel.text = "Distance to "+ str(map[node]) + " from A : " + TDlabel["TD"+str(node)].text

func highlight_shortest_path_to_bfs(target_node: int):
	_clear_all_highlights()
	
	if target_node == 1:
		BLabel.text = "Distance to "+ str(map[target_node]) + " from A : 0"
		return
		
	if !bfs.reached_nodes.has(target_node):
		print("Node ", target_node, " has not been reached yet.")
		return

	var current_node = target_node
	while current_node != source_node:
		var previous_node = bfs.predecessors[current_node]
		if previous_node == null:
			print("No predecessor found for node ", current_node, ". Path tracing stopped.")
			return

		var edge_key = str(previous_node) + "_" + str(current_node)
		if fedges.has(edge_key):
			bfs.highlight_final_edge(previous_node, current_node)
		else:
			print("Edge not found in fedges for key: ", edge_key)

		current_node = previous_node
		
	BLabel.text = "Distance to "+ str(map[target_node]) + " from A : " + str(bfs.path_dist[target_node])
	print("Shortest path to node ", target_node, " highlighted.")
