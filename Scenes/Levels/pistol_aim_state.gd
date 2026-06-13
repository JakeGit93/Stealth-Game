class_name PistolAimState
extends State

@export var character: CharacterBody3D
@export var animation_tree: AnimationTree
@export var camera_pivot: Node3D
@export var spring_arm: SpringArm3D
@export var camera: Camera3D
@export var crosshair: Control
@export var look_at : LookAtModifier3D
@export var look_at_target : Marker3D

@export_group("Movement variables")
@export var walk_speed : float = 2.0
@export var gravity : float = 50.0
@export var aim_speed : float = 15.0

var playback: AnimationNodeStateMachinePlayback

func enter() -> void:
	playback = animation_tree.get("parameters/playback")
	playback.travel("Pistol_Aim_Neutral")
	camera_pivot.set_aiming(true)
	crosshair.visible = true
	look_at.active = true

func exit() -> void:
	look_at.active = false
	camera.attributes.dof_blur_near_distance = 0.0
	camera.attributes.dof_blur_amount = 0.0
	crosshair.visible = false
	camera_pivot.set_aiming(false)


func physics_update(delta: float) -> void:

	crosshair.queue_redraw()

	if Input.is_action_just_pressed("aim"):
		exit()
		state_machine.transition_to(state_machine.get_node("Idle_State"))
		return
	
	if Input.is_action_just_pressed("roll"):
		exit()
		state_machine.transition_to(state_machine.get_node("Roll_State"))
		return

	camera_pivot.get_node("SpringArm3D").rotation.z = 0

	var cam_forward = -camera_pivot.global_transform.basis.z
	cam_forward.y = 0
	cam_forward = cam_forward.normalized()

	# Rotation always happens
	var target_angle = atan2(-cam_forward.x, -cam_forward.z)
	character.rotation.y = lerp_angle(character.rotation.y, target_angle, delta * 15)

	# Movement only when there's input
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	input.y = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")

	if input != Vector2.ZERO:
		crosshair.set_gap(100)
		var cam_right = camera_pivot.global_transform.basis.x
		cam_right.y = 0
		cam_right = cam_right.normalized()
		var move_dir = (cam_forward * input.y + cam_right * input.x).normalized()
		character.velocity.x = move_dir.x * aim_speed
		character.velocity.z = move_dir.z * aim_speed
	else:
		crosshair.set_gap(12)
		character.velocity.x = 0
		character.velocity.z = 0

	if not character.is_on_floor():
		character.velocity.y -= gravity * delta

	

	character.move_and_slide()
		
