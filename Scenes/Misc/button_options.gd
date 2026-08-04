extends Button

@export var player : AudioStreamPlayer

func _on_mouse_entered() -> void:
	player.play()
