class_name CrouchIdleState
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
	playback.travel("Crouch_Idle")
	light_detection.visibility_multiplier = 0.2

func exit() -> void:
	light_detection.visibility_multiplier = 0.5

func physics_update(delta: float) -> void:
	var move_direction : Vector2 = Vector2.ZERO
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_direction.y = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")


	if Input.is_action_just_released("crouch"):
		exit()
		state_machine.transition_to(state_machine.get_node("Idle_State"))
		return

	if Input.is_action_pressed("move_forwards") or Input.is_action_pressed("move_backwards") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		exit()
		state_machine.transition_to(state_machine.get_node("Crouch_State"))
		return
	
	if Input.is_action_just_pressed("sprint"):
		exit()
		state_machine.transition_to(state_machine.get_node("Sprint_State"))
		return

	if Input.is_action_just_pressed("roll"):
		exit()
		state_machine.transition_to(state_machine.get_node("Roll_State"))
		return
