extends Panel

@onready var icon : TextureRect = $Icon
@onready var display_name : Label = $DisplayName
@onready var description : Label = $Description

var current_achievement : String

func set_achievement (achievement : String):
	current_achievement = achievement
	
	display_name.text = Steam.getAchievementDisplayAttribute(current_achievement, "name")
	description.text = Steam.getAchievementDisplayAttribute(current_achievement, "desc")
	icon.texture = _get_icon()
	
# Fixed by Grok need to investigate why my method commented below is not working.
func _get_icon() -> ImageTexture:
	var icon_handle: int = Steam.getAchievementIcon(current_achievement)
	if icon_handle <= 0:
		return null  # Or load a default texture: load("res://path/to/default_icon.png")
	
	var icon_size: Dictionary = Steam.getImageSize(icon_handle)
	if not icon_size.has("width") or not icon_size.has("height"):
		return null  # Or load a default texture
	
	var icon_buffer: Dictionary = Steam.getImageRGBA(icon_handle)
	if not icon_buffer.has("buffer") or not icon_buffer.buffer is PackedByteArray:
		return null  # Or load a default texture
	
	var image: Image = Image.create_from_data(icon_size.width, icon_size.height, false, Image.FORMAT_RGBA8, icon_buffer.buffer)
	if image.is_empty():
		return null  # Or load a default texture
	
	return ImageTexture.create_from_image(image)

#func _get_icon () -> ImageTexture:
	#var icon_handle : int = Steam.getAchievementIcon(current_achievement)
	#var icon_size: Dictionary = Steam.getImageSize(icon_handle)
	#var icon_buffer : Dictionary = Steam.getImageRGBA(icon_handle)
	#var image : Image = Image.create_from_data(icon_size.width, icon_size.height, false, Image.FORMAT_RGBA8, icon_buffer.buffer)
	#return ImageTexture.create_from_image(image)

func _on_unlock_button_pressed() -> void:
	SteamController.set_achievement(current_achievement)
	_get_icon()
