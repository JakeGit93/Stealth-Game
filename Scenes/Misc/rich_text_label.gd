extends RichTextLabel

@onready var startup_text := "///...
Bootloader JJk399937HAK28DAA H://Root/Index/Users/Admin/System
///...
///...
///...
///...
Euler 2
Production ready computer operating system
Copyright Euler Computers & Software Corporation
///...
///...
///...
"

@onready var secondary_text := "Please Enter a Command.
For a list of options, type Help
To shutdown, Press ESC
"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for character in range(startup_text.length()):
		self.append_text(startup_text[character])
		await get_tree().create_timer(0.05).timeout
	
	self.clear()
	self.append_text(secondary_text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_audio_stream_player_2d_ready() -> void:
	%AudioStreamPlayer.play()
