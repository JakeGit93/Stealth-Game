class_name CrouchState
extends State

@export var character: CharacterBody3D
@export var animation_tree: AnimationTree
@export var camera_pivot: Node3D
@export var light_detection: Node3D

@export_group("Movement variables")
@export var crouch_speed : float = 1.0
@export var jump_strength : float = 12.0
@export var gravity : float = 50.0

var playback: AnimationNodeStateMachinePlayback

func enter() -> void:
	playback = animation_tree.get("parameters/playback")
	playback.travel("Crouch_Fwd")
	light_detection.visibility_multiplier = 0.2

func exit() -> void:
	light_detection.visibility_multiplier = 0.5


func physics_update(delta: float) -> void:
	var move_direction : Vector2 = Vector2.ZERO
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_direction.y = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")


	if move_direction == Vector2.ZERO:
		exit()
		state_machine.transition_to(state_machine.get_node("Crouch_Idle_State"))
		return

	if Input.is_action_just_released("crouch"):
		exit()
		state_machine.transition_to(state_machine.get_node("Idle_State"))
		return

	
	if Input.is_action_just_pressed("sprint"):
		exit()
		state_machine.transition_to(state_machine.get_node("Sprint_State"))
		return

	if Input.is_action_just_pressed("aim"):
		exit()
		state_machine.transition_to(state_machine.get_node("Pistol_Aim_State"))
		return

	if Input.is_action_just_pressed("roll"):
		exit()
		state_machine.transition_to(state_machine.get_node("Roll_State"))
		return

	

	var cam_forward = camera_pivot.global_transform.basis.z
	var cam_right = camera_pivot.global_transform.basis.x
	cam_forward.y = 0
	cam_right.y = 0
	cam_forward = cam_forward.normalized()
	cam_right = cam_right.normalized()
	
	var move_dir = (cam_forward * move_direction.y + cam_right * move_direction.x).normalized()

	var target_angle = atan2(-move_dir.x, -move_dir.z)
	character.rotation.y = lerp_angle(character.rotation.y, target_angle, delta * 10)

	character.velocity.x = -move_dir.x * crouch_speed
	character.velocity.z = -move_dir.z * crouch_speed

	if not character.is_on_floor():
		character.velocity.y -= gravity * delta

	character.move_and_slide()
