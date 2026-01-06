extends Node3D

@export var player : CharacterBody3D

@onready var detected : bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if detected == true:
		self.look_at(player.position)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		detected = true
		print("player seen by enemy")


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player:
		detected = false
		print("player not seen by enemy")
