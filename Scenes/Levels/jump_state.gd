class_name JumpState
extends State

@export var character: CharacterBody3D
@export var animation_tree: AnimationTree

func enter() -> void:
    animation_tree.set("parameters/Jump/playback", "Jump_Start")

func physics_update(delta: float) -> void:
# Apply gravity even while idle
    if not character.is_on_floor():
        state_machine.transition_to(state_machine.get_node("Fall_State"))
        return


    if Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards") != Vector2.ZERO:
        state_machine.transition_to(state_machine.get_node("Walk_State"))
        