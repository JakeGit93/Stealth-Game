extends MeshInstance3D

@export var max_radius: float = 5.0
@export var duration: float = 0.5

func _ready() -> void:
	scale = Vector3.ZERO
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector3.ONE * max_radius, duration)
	tween.finished.connect(queue_free)