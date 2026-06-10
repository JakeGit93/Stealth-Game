class_name IdleState
extends State

@export var character: CharacterBody3D
@export var animation_tree: AnimationTree
@export var camera: Camera3D

var playback: AnimationNodeStateMachinePlayback


func enter() -> void:
	camera.attributes.dof_blur_near_distance = 0.0
	camera.attributes.dof_blur_amount = 0.0
	playback = animation_tree.get("parameters/playback")
	playback.travel("Idle")

func physics_update(delta: float) -> void:
	if Input.is_action_pressed("move_forwards") or Input.is_action_pressed("move_backwards") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		state_machine.transition_to(state_machine.get_node("Walk_State"))
	
	if Input.is_action_pressed("crouch"):
		state_machine.transition_to(state_machine.get_node("Crouch_Idle_State"))

	if Input.is_action_just_pressed("aim"):
		state_machine.transition_to(state_machine.get_node("Pistol_Aim_State"))
		return

	if Input.is_action_just_pressed("roll"):
		state_machine.transition_to(state_machine.get_node("Roll_State"))
		return

		
	#if Input.is_action_just_pressed("jump"):
		#state_machine.transition_to(state_machine.get_node("Jump_State"))
		