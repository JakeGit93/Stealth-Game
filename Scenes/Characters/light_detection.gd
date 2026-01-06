extends Node3D

@onready var actual_top_camera : Camera3D = $TopCamViewport/TopCamera
@onready var actual_bot_camera : Camera3D = $BotCamViewport/BotCamera
@onready var top_camera : SubViewport = $TopCamViewport
@onready var bot_camera : SubViewport = $BotCamViewport
@onready var current_top_frame : ViewportTexture
@onready var current_bot_frame : ViewportTexture
@onready var top_lum : float
@onready var bot_lum : float
@onready var player : CharacterBody3D = $".."
@onready var progress_bar : ProgressBar = $"../SpringArmPivot/SpringArm3D/Camera3D/LightViewer/Control2/ProgressBar"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	actual_top_camera.global_position = player.global_position
	actual_top_camera.global_position.y = player.global_position.y + 2
	actual_bot_camera.global_position = player.global_position
	# waiting until a frame is actually drawn
	await RenderingServer.frame_post_draw
	#getting the viewport frames and converting them to textures
	current_top_frame = top_camera.get_texture()
	current_bot_frame = bot_camera.get_texture()
	#converting the viewport textures into single pixel color values and calculating their luminance
	top_lum = _get_col(current_top_frame).get_luminance()
	bot_lum = _get_col(current_bot_frame).get_luminance()
	var combined_values = (bot_lum + top_lum) * 0.5
	print(combined_values)
	
	var tween := create_tween()
	tween.tween_property(progress_bar, "value", combined_values, 0.1)
	
#converts a ViewportTexture into a single pixel
func _get_col(camera_texture: ViewportTexture) -> Color:
	var img = camera_texture.get_image()
	img.resize(1,1, Image.INTERPOLATE_LANCZOS)
	return img.get_pixel(0,0)
	
