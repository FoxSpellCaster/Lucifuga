extends Panel

@onready var icon : TextureRect = $Icon
@onready var display_name : Label = $DisplayName
@onready var description : Label = $Description

var current_achievement : String

func set_achievement (achievement : String):
	pass

func _get_icon ():
	pass

func _on_unlock_button_pressed() -> void:
	SteamController.set_achievement(current_achievement)
