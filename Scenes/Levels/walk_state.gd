class_name WalkState
extends State

@export var character: CharacterBody3D
@export var animation_tree: AnimationTree
@export var camera_pivot: Node3D
@export var right_two_bone: TwoBoneIK3D
@export var left_two_bone: TwoBoneIK3D
@export var right_detection: Area3D
@export var left_detection: Area3D

@export_group("Movement variables")
@export var walk_speed : float = 2.0
@export var jump_strength : float = 12.0
@export var gravity : float = 50.0

@onready var right_rays: Array[RayCast3D] = _ray_array(right_detection)
@onready var left_rays: Array[RayCast3D] = _ray_array(left_detection)
@export var new_target: Marker3D
@onready var target_bool := false

var playback: AnimationNodeStateMachinePlayback


func enter() -> void:
	playback = animation_tree.get("parameters/playback")
	playback.travel("Walk")

	for rays in left_rays:
		rays.enabled = true
	
	for rays in right_rays:
		rays.enabled = true
	


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# STUFF TO DO WITH THE RAY CASTS AND AREA3Ds FOR DETECTING THINGS NEARBY
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@onready var right_body_list: Array = []
@onready var left_body_list: Array = []

#these signals handle which bodies are inside the areas
func _on_right_detection_body_entered(body: Node3D) -> void:
	right_body_list.append(body)

func _on_right_detection_body_exited(body: Node3D) -> void:
	right_body_list.erase(body)

func _on_left_detection_body_entered(body: Node3D) -> void:
	left_body_list.append(body)

func _on_left_detection_body_exited(body: Node3D) -> void:
	left_body_list.erase(body)

#literally just prevents us from having to declare each ray node in code lmao
func _ray_array(parent: Node) -> Array[RayCast3D]:
	var rays: Array[RayCast3D] = []
	for child in parent.get_children():
		if child is RayCast3D:
			rays.append(child)

	return rays

#returns shortest ray collision point and normal
func ray_collision(rays: Array[RayCast3D]) -> Dictionary:
	var best_dist := INF
	var best_hit := {}

	for ray in rays:
		if ray.is_colliding():
			var point = ray.get_collision_point()
			var dist = ray.global_position.distance_to(point)
			if dist < best_dist:
				best_dist = dist
				best_hit = {
					"point": point,
					"normal": ray.get_collision_normal()
				}
	return best_hit



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# GENERAL STUFF
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


func physics_update(delta: float) -> void:
	var move_direction : Vector2 = Vector2.ZERO
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_direction.y = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")


	if move_direction == Vector2.ZERO:
		state_machine.transition_to(state_machine.get_node("Idle_State"))
		return
	
	if Input.is_action_pressed("sprint"):
		state_machine.transition_to(state_machine.get_node("Sprint_State"))


	if Input.is_action_just_pressed("crouch"):
		state_machine.transition_to(state_machine.get_node("Crouch_Idle_State"))

	if Input.is_action_just_pressed("aim"):
		state_machine.transition_to(state_machine.get_node("Pistol_Aim_State"))
		return

	if Input.is_action_just_pressed("roll"):
		state_machine.transition_to(state_machine.get_node("Roll_State"))
		return

	var cam_forward = camera_pivot.global_transform.basis.z
	var cam_right = camera_pivot.global_transform.basis.x
	cam_forward.y = 0
	cam_right.y = 0
	cam_forward = cam_forward.normalized()
	cam_right = cam_right.normalized()
	
	var move_dir = (cam_forward * move_direction.y + cam_right * move_direction.x).normalized()

	var target_angle = atan2(-move_dir.x, -move_dir.z)
	character.rotation.y = lerp_angle(character.rotation.y, target_angle, delta * 20)

	character.velocity.x = -move_dir.x * walk_speed
	character.velocity.z = -move_dir.z * walk_speed

	if not character.is_on_floor():
		character.velocity.y -= gravity * delta

	#RAY SHIT ~~~~~~~~~~~~~~~~
	#new_target.position = left_rays[0].get_collision_point()
	#left_two_bone.set_target_node(0, new_target.get_path())
		





	character.move_and_slide()
		
