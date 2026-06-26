extends Weapon

@export var bullet_scene: PackedScene
@export var muzzle: Node3D
@export var bullet_speed: int
@export var audio_stream: AudioStreamPlayer3D

func fire() -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.global_rotation = muzzle.global_rotation
	bullet.linear_velocity =  muzzle.global_transform.basis.y * bullet_speed
	audio_stream.play()
