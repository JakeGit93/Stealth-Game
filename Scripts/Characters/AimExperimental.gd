extends Node3D

@export_group("FOV")
@export var normal_fov : float = 75.0

@export_group("Camera Position")
@export var spring_pos1 : float = 0.8
@export var spring_pos2 : float = -0.8
@export var aim_pos1 : float = 1.5
@export var aim_pos2 : float = 1.5

const CAMERA_BLEND : float = 0.05

@export_group("Nodes")
@export var head : Node3D
@export var spring_arm : SpringArm3D 
@export var camera : Camera3D 
@export var character : CharacterBody3D
@export var skeleton : Skeleton3D
@export var model : MeshInstance3D
@export var normal_length: float = 3.0
@export var aim_length: float = 2.5
@export var spine_rotator: LookAtModifier3D
@export var IK_target: Marker3D
@onready var spring_bool: bool = true
var target_length: float
var target_x: float


func _ready():
	target_length = normal_length
	spring_arm.position.y = aim_pos1
	spring_arm.spring_length = normal_length
	spring_arm.position.x = spring_pos2

func set_aiming(is_aiming: bool) -> void:
	target_length = aim_length if is_aiming else normal_length
	spring_arm.position.y = aim_pos2 if is_aiming else aim_pos1


func _process(delta: float) -> void:
	global_position = character.global_position
	spring_arm.spring_length = lerp(spring_arm.spring_length, target_length, delta * 10.0)


func _physics_process(delta):
	if Input.is_action_just_pressed("swap_shoulder"):
		target_x = spring_pos2 if !spring_bool else spring_pos1
		spring_bool = !spring_bool

		var t := create_tween()
		t.tween_property(spring_arm, "position:x", target_x, 0.25)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN_OUT)


func _on_spine_rotator_modification_processed() -> void:
	if spine_rotator.is_target_within_limitation():
		spine_rotator.influence = lerp(spine_rotator.influence, 1.0, get_physics_process_delta_time() * 5.0)
	else:
		spine_rotator.influence = lerp(spine_rotator.influence, 0.0, get_physics_process_delta_time() * 5.0)
