extends RigidBody3D
@export var bullet_hole: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	queue_free()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	for i in state.get_contact_count():
		var normal = state.get_contact_local_normal(i)
		var position = state.get_contact_local_position(i)
		#spawn_decal(position, normal)

func spawn_decal(position: Vector3, normal: Vector3) -> void:
	var decal = Decal.new()
	get_tree().root.add_child(decal)
	decal.set_texture(Decal.TEXTURE_ALBEDO, bullet_hole)
	decal.global_position = position
	decal.look_at(position + normal, Vector3.UP)
