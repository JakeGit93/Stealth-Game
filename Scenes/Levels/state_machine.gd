class_name StateMachine
extends Node

@export_group("State variables")
@export var animation_tree : AnimationTree
@export var initial_state : State
@export var character : CharacterBody3D

var current_state: State

func _ready() -> void:
	for child in get_children():
		child.state_machine = self
	transition_to(initial_state)

func transition_to(new_state: State) -> void:
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()

func _unhandled_input(event: InputEvent) -> void:
	current_state.handle_input(event)

func _process(delta: float) -> void:
	current_state.update(delta)


func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)
