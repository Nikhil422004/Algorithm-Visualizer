extends TextureButton

# Reference to the TextureRect
@onready var hover_image = $"../Help"

func _on_mouse_entered():
	hover_image.visible = true

func _on_mouse_exited():
	hover_image.visible = false
