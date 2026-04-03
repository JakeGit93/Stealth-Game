extends Line2D

@onready var point_range := 100

func _ready() -> void:
	pass

func _process(delta):
	clear_points()
	for i in range(point_range):
		self.add_point(Vector2(i * 10, randi_range(0, 1 / abs(i - point_range * 0.5) * -100)))
