extends Weapon

@export var bullet_scene: PackedScene
@export var muzzle: Node3D
@export var bullet_speed: int
@export var audio_stream: AudioStreamPlayer3D

func fire() -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.global_transform = muzzle.global_transform
	bullet.scale = Vector3(2.0,2.0,2.0)
	bullet.linear_velocity =  bullet_speed * Vector3.ONE
	audio_stream.play()
