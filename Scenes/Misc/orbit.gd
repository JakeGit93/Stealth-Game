extends Node3D

## OrbitCamera.gd
## Attach this script to a Node3D that acts as the camera pivot/rig.
## Place your Camera3D as a child of this node, offset along -Z (e.g. position.z = 5).
##
## Controls:
##   Left Mouse Drag   → Orbit (rotate around target)
##   Middle Mouse Drag → Pan (move target point)
##   W / S             → Move forward / backward
##   A / D             → Strafe left / right

# ---------------------------------------------------------------------------
# Exported settings
# ---------------------------------------------------------------------------

@export_group("Orbit")
@export var orbit_sensitivity: float = 0.3   ## Degrees per pixel dragged

@export_group("Pan")
@export var pan_sensitivity: float = 0.005   ## World units per pixel dragged

@export_group("WASD Movement")
@export var move_speed: float = 5.0          ## World units per second

# ---------------------------------------------------------------------------
# Internal state
# ---------------------------------------------------------------------------

var _orbiting: bool = false
var _panning:  bool = false


func _input(event: InputEvent) -> void:

	# ── Button press / release ────────────────────────────────────────────
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_orbiting = event.pressed
			MOUSE_BUTTON_MIDDLE:
				_panning = event.pressed

	# ── Mouse motion ──────────────────────────────────────────────────────
	if event is InputEventMouseMotion:
		if _orbiting:
			_orbit(event.relative)
		elif _panning:
			_pan(event.relative)


func _process(delta: float) -> void:
	_handle_wasd(delta)


# ---------------------------------------------------------------------------
# Orbit: rotate the rig around the world-up axis (yaw) and its local X (pitch)
# ---------------------------------------------------------------------------
func _orbit(delta: Vector2) -> void:
	# Yaw around global Y so the horizon stays level
	rotate_y(deg_to_rad(-delta.x * orbit_sensitivity))

	# Pitch around local X; clamp so the camera never flips past the poles
	var new_pitch: float = rotation_degrees.x + (-delta.y * orbit_sensitivity)
	rotation_degrees.x = clamp(new_pitch, -89.0, 89.0)


# ---------------------------------------------------------------------------
# Pan: translate the entire rig in its local XY plane
# ---------------------------------------------------------------------------
func _pan(delta: Vector2) -> void:
	var pan_vec := Vector3(
		-delta.x * pan_sensitivity,
		 delta.y * pan_sensitivity,
		0.0
	)
	translate(pan_vec)


# ---------------------------------------------------------------------------
# WASD: move the rig relative to its current facing direction
# ---------------------------------------------------------------------------
func _handle_wasd(delta: float) -> void:
	var direction := Vector3.ZERO

	# Derive a flat forward vector from the rig's yaw only, ignoring pitch.
	# This ensures W/S always move horizontally forward/back in world space
	# regardless of how far the camera is tilted up or down.
	var yaw_basis := Basis(Vector3.UP, rotation.y)
	var forward := -yaw_basis.z   # Local -Z flattened to the XZ plane
	var right   :=  yaw_basis.x   # Local +X

	if Input.is_key_pressed(KEY_W):
		direction += forward
	if Input.is_key_pressed(KEY_S):
		direction -= forward
	if Input.is_key_pressed(KEY_A):
		direction -= right
	if Input.is_key_pressed(KEY_D):
		direction += right
	if Input.is_key_pressed(KEY_SHIFT):
		direction += Vector3.UP
	if Input.is_key_pressed(KEY_CTRL):
		direction += Vector3.DOWN

	if direction != Vector3.ZERO:
		global_translate(direction.normalized() * move_speed * delta)