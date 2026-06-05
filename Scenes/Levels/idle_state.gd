class_name IdleState
extends State

@export var character: CharacterBody3D
@export var animation_tree: AnimationTree

var playback: AnimationNodeStateMachinePlayback


func enter() -> void:
    playback = animation_tree.get("parameters/playback")
    playback.travel("Idle")

func physics_update(delta: float) -> void:
    # Apply gravity even while idle
    #if not character.is_on_floor():
        #state_machine.transition_to(state_machine.get_node("Fall_State"))
        #return
    pass


    if Input.is_action_pressed("move_forwards"):
        state_machine.transition_to(state_machine.get_node("Walk_State"))

        
    #if Input.is_action_just_pressed("jump"):
        #state_machine.transition_to(state_machine.get_node("Jump_State"))
        