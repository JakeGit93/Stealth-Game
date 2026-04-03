extends LineEdit

@onready var text_box = %RichTextLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_text_submitted(new_text: String) -> void:
	print("confirmed input: ", new_text)
	text_box.append_text(new_text)
	text_box.append_text("\n")
	self.menu_option(LineEdit.MENU_CLEAR)
	grab_focus()
	
