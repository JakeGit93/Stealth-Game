class_name RollState
extends State

@export var character: CharacterBody3D
@export var camera_pivot: Node3D
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var roll_speed: float = 10.0
@export var gravity: float = 50.0

var playback: AnimationNodeStateMachinePlayback
var is_rolling: bool = false
var roll_direction: Vector3

func enter() -> void:
	playback = animation_tree.get("parameters/playback")

	is_rolling = true
	roll_direction = Vector3(character.velocity.x, 0, character.velocity.z).normalized()

	if roll_direction == Vector3.ZERO:
		roll_direction = -camera_pivot.global_transform.basis.z
		roll_direction.y = 0
		roll_direction = roll_direction.normalized()
	playback.travel("Roll")

func exit() -> void:
	is_rolling = false

func physics_update(delta: float) -> void:
	if is_rolling:
		if playback.get_current_node() == "Roll" and playback.get_current_play_position() < playback.get_current_length() - 0.5:
			character.velocity.x = roll_direction.x * roll_speed
			character.velocity.z = roll_direction.z * roll_speed
			if not character.is_on_floor():
				character.velocity.y -= gravity * delta
			character.move_and_slide()
			return
		else:
			is_rolling = false

	state_machine.transition_to(state_machine.get_node("Idle_State"))
