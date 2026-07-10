extends Node3D


@export var light = SpotLight3D
@export var sparks = Node3D
@export var rigidbod = RigidBody3D
@export var audio = AudioStreamPlayer3D


@export var mesh_instance_path : NodePath
@onready var lightmesh : MeshInstance3D = get_node(mesh_instance_path)
@onready var mat: Material

func _ready() -> void:
	var duplicate_mesh = lightmesh.mesh.duplicate(true)
	lightmesh.mesh = duplicate_mesh
	mat = duplicate_mesh.surface_get_material(1)

func _on_rigid_body_3d_body_entered(body: Node) -> void:
	mat.emission_energy_multiplier = 0.0
	light.visible = false
	sparks.emitting = true
	rigidbod.sleeping = true
	audio.playing = true
	print("entered")
