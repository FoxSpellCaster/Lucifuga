extends Control

# UI nodes
@onready var avatar_texture: TextureRect = $VBoxContainer/AvatarContainer/Avatar
@onready var name_label: Label = $VBoxContainer/NameLabel

func _ready() -> void:
	# Check Steam initialization
	if not SteamController or not SteamController.enable_steam or not Steam.isSteamRunning():
		update_ui_offline()
		return
	
	# Verify TextureRect
	if not avatar_texture:
		push_error("Avatar TextureRect node not found")
		update_ui_offline()
		return
	
	# Set username
	var username: String = Steam.getPersonaName()
	name_label.text = username if username else "Unknown"
	print("Username: ", username)
	
	# Load avatar
	var steam_id: int = Steam.getSteamID()
	print("Steam ID: ", steam_id)
	if steam_id:
		load_steam_avatar(steam_id)
	else:
		avatar_texture.texture = null
		print("No valid Steam ID")

func update_ui_offline() -> void:
	name_label.text = "Offline"
	if avatar_texture:
		avatar_texture.texture = null
	print("Steam offline or not initialized")

func load_steam_avatar(steam_id: int) -> void:
	# Get avatar ID (medium, 64x64)
	var avatar_id: int = Steam.getMediumFriendAvatar(steam_id)
	print("Avatar ID: ", avatar_id)
	if avatar_id <= 0:
		avatar_texture.texture = null
		print("Invalid avatar ID")
		return
	
	# Get avatar data
	var avatar_data: Dictionary = Steam.getImageRGBA(avatar_id)
	if not avatar_data.get("success", false):
		avatar_texture.texture = null
		print("Avatar data failed")
		return
	
	# Extract dimensions and buffer
	var width: int = avatar_data.get("width", 0)
	var height: int = avatar_data.get("height", 0)
	var buffer: PackedByteArray = avatar_data.get("buffer", PackedByteArray())
	print("Avatar width: ", width, ", height: ", height)
	print("Buffer size: ", buffer.size())
	
	if width <= 0 or height <= 0 or buffer.is_empty():
		avatar_texture.texture = null
		print("Invalid dimensions or buffer")
		return
	
	# Create image
	var image := Image.new()
	var error: int = image.create_from_data(width, height, false, Image.FORMAT_RGBA8, buffer)
	if error != OK or image.is_empty():
		avatar_texture.texture = null
		print("Image creation failed, error: ", error)
		return
	print("Image created")
	
	# Create texture
	var texture := ImageTexture.create_from_image(image)
	if not texture:
		avatar_texture.texture = null
		print("Texture creation failed")
		return
	avatar_texture.texture = texture
	print("Texture applied")
	
	# Verify TextureRect
	print("TextureRect visible: ", avatar_texture.visible)
	print("TextureRect size: ", avatar_texture.size)
