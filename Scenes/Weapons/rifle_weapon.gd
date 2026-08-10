extends Weapon

@export var bullet_scene: PackedScene
@export var muzzle: Node3D
@export var bullet_speed: int
@export var audio_stream: RaytracedAudioPlayer3D
@export var timer: Timer
@export var fire_rate: float

@onready var ik_attachL: Node3D = %IKL
@onready var ik_attachR: Node3D = %IKR

func _ready() -> void:
	timer.wait_time = fire_rate



func fire() -> void:
	if !timer.is_stopped():
		pass
	else:
		timer.start()
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		bullet.global_position = muzzle.global_position
		bullet.global_rotation = muzzle.global_rotation
		bullet.linear_velocity =  muzzle.global_transform.basis.z * bullet_speed
		audio_stream.play()
