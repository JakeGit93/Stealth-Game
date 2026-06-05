class_name WalkState
extends State

@export var character: CharacterBody3D
@export var animation_tree: AnimationTree

var playback: AnimationNodeStateMachinePlayback

func enter() -> void:
    playback = animation_tree.get("parameters/playback")
    playback.travel("Walk")


func physics_update(delta: float) -> void:
    if Input.is_action_just_released("move_forwards"):
        state_machine.transition_to(state_machine.get_node("Idle_State"))
    else:
        character.velocity.z = 100 * delta
        print(character.position.z)
    
    character.move_and_slide()
        

    #logic for walking
        