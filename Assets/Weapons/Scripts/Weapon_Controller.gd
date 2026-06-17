class_name WeaponController extends Node

@export var weapon_handler: Node3D
@export var weapon: PackedScene

var current_weapon

func _ready() -> void:
	equip(weapon)


func equip(scene: PackedScene) -> void:
	if current_weapon:
		current_weapon.queue_free()

	current_weapon = scene.instantiate()
	weapon_handler.add_child(current_weapon)





