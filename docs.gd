extends Node

func _ready():
	var richtext = $RichTextLabel
	richtext.clear()
	richtext.bbcode_text = """

[b]Developer:[/b] Nikhil S Thomas  
[b]Mentor:[/b] Dr. Krithika Ramaswamy  

[b]Project Details:[/b]  
This project is an Algorithm Visualizer, developed as part of an Open-Ended Lab Project.  
The visualizer primarily focuses on shortest path algorithms, offering an intuitive understanding of Dijkstra's algorithm and its relation to an extended BFS. It demonstrates these algorithms step-by-step, allowing users to explore and analyze their behavior in a visually engaging way.

[b]Key Features:[/b]  
- [i]Interactive Step-Based Visualization:[/i] Users can control the animation of the algorithms using keyboard inputs, stepping forward or backward through each phase.  
- [i]Edge Highlighting:[/i] Edges are highlighted dynamically during the visualization to indicate the progress of the algorithm. The shortest path is emphasized in green once the trace is complete.  
- [i]Custom Ripple Effect for BFS:[/i] A unique ripple effect visually represents the BFS traversal, divided proportionally to edge weights.  
- [i]Priority Queue Display:[/i] For Dijkstra's algorithm, the priority queue is visualized, showing how elements are prioritized and popped one by one. This step-by-step popping helps users understand how Dijkstra's algorithm progresses in finding the shortest path.
- [i]State Management:[/i] The application maintains a stack of states, enabling users to navigate between the initial, intermediate, and final states effortlessly.  
- [i]Timers and Labels:[/i] Displays dynamic countdowns and distance estimates for nodes, giving real-time feedback on traversal progress.

[b]Objective:[/b]  
The goal of this project is to make complex algorithms accessible and engaging. By simulating a "race" between edges and highlighting key concepts, it bridges the gap between theoretical knowledge and intuitive understanding.

[b]Applications:[/b]  
This visualizer is particularly useful for educational purposes, helping students and educators explain and understand shortest path algorithms.  

For more information, refer to the documentation below:  
[url=https://docs.google.com/document/d/1oCBGQ_taf2hb-Bvc7EgKaZaT95FaaAuf4MN0K7RNv8U/]Docs[/url]
"""
	richtext.connect("meta_clicked", Callable(self, "_on_meta_clicked"))
	
func _on_meta_clicked(meta: String) -> void:
	OS.shell_open(meta)  # Open the URL in the default browser
