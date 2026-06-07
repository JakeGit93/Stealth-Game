extends Node3D

@export_group("FOV")
@export var normal_fov : float = 75.0

@export_group("Camera Position")
@export var spring_pos1 : float = 0.8
@export var spring_pos2 : float = -0.8

const CAMERA_BLEND : float = 0.05

@export var spring_arm : SpringArm3D 
@export var camera : Camera3D 


@onready var spring_bool : bool = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		spring_arm.rotate_object_local(Vector3.RIGHT, -event.relative.y * 0.005)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)

func _physics_process(_delta):
	
	if Input.is_action_just_pressed("swap_shoulder"):
		var target_x = spring_pos2 if spring_bool else spring_pos1
		spring_bool = !spring_bool

		var t := create_tween()
		t.tween_property(spring_arm, "position:x", target_x, 0.25)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN_OUT)