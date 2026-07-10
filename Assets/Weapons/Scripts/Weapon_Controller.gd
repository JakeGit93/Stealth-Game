class_name WeaponController extends Node

@export var weapon_handler: Node3D
@export var weapon: PackedScene
@export var bone_attach: BoneAttachment3D
@export var two_bone_L : TwoBoneIK3D
@export var two_bone_R : TwoBoneIK3D


var current_weapon

func _ready() -> void:
	equip(weapon)


func equip(scene: PackedScene) -> void:
	if current_weapon:
		current_weapon.queue_free()

	current_weapon = scene.instantiate()
	weapon_handler.add_child(current_weapon)
	var ik_target_L = current_weapon.ik_attachL
	two_bone_L.set_target_node(0, ik_target_L.get_path())
	var ik_target_R = current_weapon.ik_attachR
	two_bone_R.set_target_node(0, ik_target_R.get_path())
	#var path = ik_target.get_path()
	#two_bone.set_target_node(0,path)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fire"):
		current_weapon.fire()


	
