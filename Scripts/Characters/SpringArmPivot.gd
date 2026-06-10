extends Node3D

@export_group("FOV")
@export var normal_fov : float = 75.0

@export_group("Camera Position")
@export var spring_pos1 : float = 0.8
@export var spring_pos2 : float = -0.8
@export var aim_pos1 : float = 1
@export var aim_pos2 : float = 1.5

const CAMERA_BLEND : float = 0.05

@export var spring_arm : SpringArm3D 
@export var camera : Camera3D 
@export var target : CharacterBody3D
@export var skeleton : Skeleton3D
@export var model : MeshInstance3D
@export var normal_length: float = 5.0
@export var aim_length: float = 2.5
var target_length: float
var target_x: float


@onready var spring_bool: bool = true

func _ready():
	target_length = normal_length
	spring_arm.spring_length = normal_length
	spring_arm.position.x = spring_pos2
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func set_aiming(is_aiming: bool) -> void:
	target_length = aim_length if is_aiming else normal_length
	spring_arm.position.y = aim_pos2 if is_aiming else aim_pos1

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera.rotation.z = 0
		rotate_y(-event.relative.x * 0.005)
		spring_arm.rotate_object_local(Vector3.RIGHT, -event.relative.y * 0.005)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)

func _physics_process(delta):
	global_position = target.global_position
	spring_arm.rotation.z = 0

	spring_arm.spring_length = lerp(spring_arm.spring_length, target_length, delta * 10.0)
	
	if Input.is_action_just_pressed("swap_shoulder"):
		target_x = spring_pos2 if !spring_bool else spring_pos1
		spring_bool = !spring_bool
		skeleton.scale.x = -1 if spring_bool else 1

		var t := create_tween()
		t.tween_property(spring_arm, "position:x", target_x, 0.25)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN_OUT)
