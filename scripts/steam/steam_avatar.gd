extends TextureRect

func _ready():
	# Connect to the avatar_loaded signal
	Steam.avatar_loaded.connect(_on_avatar_loaded)
	
	# Request the player's avatar
	Steam.getPlayerAvatar(Steam.AVATAR_LARGE, Steam.getSteamID())
	

func _on_avatar_loaded(user_id: int, avatar_size: int, avatar_buffer: PackedByteArray):
	# Convert the raw data into an Image
	var image: Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)
	
	# Convert the Image into an ImageTexture, then apply it
	var image_tex: ImageTexture = ImageTexture.create_from_image(image)
	texture = image_tex
