extends Control

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://home_page.tscn")

func _on_mouse_entered() -> void:
	set_default_cursor_shape(CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	set_default_cursor_shape(CURSOR_ARROW)
