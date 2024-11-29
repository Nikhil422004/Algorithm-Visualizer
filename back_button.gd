extends TextureButton

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://home_page.tscn")


func _on_mouse_entered() -> void:
	set_default_cursor_shape(CURSOR_POINTING_HAND)
