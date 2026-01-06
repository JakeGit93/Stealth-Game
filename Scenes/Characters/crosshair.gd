extends Control

@export var line_length: float = 15.0
@export var line_thickness: float = 2.0
@export var gap: float
@export var color: Color = Color.GREEN
@export var outline_color: Color = Color.BLACK
@export var outline_size: float = 2.0   # pixels

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw():
	var cx = size.x * 0.5
	var cy = size.y * 0.5
	var half = line_length
	var g = gap

	# The 4 outline offsets
	var offsets = [
		Vector2(outline_size, 0),
		Vector2(-outline_size, 0),
		Vector2(0, outline_size),
		Vector2(0, -outline_size),
	]

	# Draw outline first
	for o in offsets:
		_draw_crosshair_at_offset(cx, cy, half, g, outline_color, line_thickness, o)

	# Draw the main crosshair
	_draw_crosshair_at_offset(cx, cy, half, g, color, line_thickness)


func _draw_crosshair_at_offset(cx, cy, half, g, col, thick, offset := Vector2.ZERO):
	# Horizontal left
	draw_line(
		Vector2(cx - g, cy) + offset,
		Vector2(cx - (half + g), cy) + offset,
		col, thick
	)

	# Horizontal right
	draw_line(
		Vector2(cx + g, cy) + offset,
		Vector2(cx + (half + g), cy) + offset,
		col, thick
	)

	# Vertical up
	draw_line(
		Vector2(cx, cy - g) + offset,
		Vector2(cx, cy - (half + g)) + offset,
		col, thick
	)

	# Vertical down
	draw_line(
		Vector2(cx, cy + g) + offset,
		Vector2(cx, cy + (half + g)) + offset,
		col, thick
	)
	
var tween: Tween

func set_gap(v: float):
	if tween:
		tween.kill()

	tween = get_tree().create_tween()
	tween.tween_property(self, "gap", v, 0.08)
	tween.tween_callback(queue_redraw)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
