extends Control

func _on_gui_input(event: InputEvent, graph: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		print(graph)
		get_tree().change_scene_to_file("res://Graph" + str(graph) + ".tscn")

func _on_mouse_entered() -> void:
	set_default_cursor_shape(CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	set_default_cursor_shape(CURSOR_ARROW)

func _on_docs_pressed() -> void:
	get_tree().change_scene_to_file("res://Docs.tscn")
