extends Node3D


@export var light = SpotLight3D
@export var sparks = Node3D
@export var rigidbod = RigidBody3D
@export var lightmesh = MeshInstance3D
@export var audio = AudioStreamPlayer3D

@onready var mat

func _ready() -> void:
	lightmesh = lightmesh.mesh.duplicate()
	mat = lightmesh.surface_get_material(1)

func _on_rigid_body_3d_body_entered(body: Node) -> void:
	mat.emission_energy_multiplier = 0.0
	light.visible = false
	sparks.emitting = true
	rigidbod.sleeping = true
	audio.playing = true
	print("entered")
