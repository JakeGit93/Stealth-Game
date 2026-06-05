class_name FallState
extends State

@export var character: CharacterBody3D
@export var animation_tree: AnimationTree

func enter() -> void:
	animation_tree.set("parameters/playback", "Fall")

func physics_update(delta: float) -> void:
	pass
