extends Control

# References to UI nodes
@onready var avatar_texture: TextureRect = $VBoxContainer/AvatarContainer/Avatar
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var steam_id_label: Label = $VBoxContainer/SteamIDLabel
@onready var online_status_label: Label = $VBoxContainer/OnlineStatusLabel
@onready var ownership_label: Label = $VBoxContainer/OwnershipLabel
@onready var language_label: Label = $VBoxContainer/LanguageLabel
@onready var steam_deck_label: Label = $VBoxContainer/SteamDeckLabel

# Placeholder texture for failed avatar loads
@export var placeholder_texture: Texture2D = preload("res://Items/Icons/Shard1.png")

func _ready() -> void:
	# Check if SteamController exists and Steam is initialized
	if not SteamController or not SteamController.enable_steam:
		update_ui_offline()
		return
	
	# Fetch and display Steam data
	var username: String = Steam.getPersonaName()
	name_label.text = "Player: %s" % (username if username else "Unknown")
	
	# Set avatar and Steam ID
	var steam_id: int = Steam.getSteamID()
	steam_id_label.text = "Steam ID: %d" % steam_id
	if steam_id:
		load_steam_avatar(steam_id)
	else:
		avatar_texture.texture = placeholder_texture
		push_warning("No valid Steam ID for avatar loading")
	
	var is_online: bool = Steam.loggedOn()
	var persona_state: int = Steam.getFriendPersonaState(steam_id) if is_online and steam_id else 0
	online_status_label.text = "Status: %s" % persona_state_to_string(persona_state)
	
	var is_owned: bool = Steam.isSubscribed()
	ownership_label.text = "Game Owned: %s" % ("Yes" if is_owned else "No")
	
	var game_language: String = Steam.getCurrentGameLanguage()
	language_label.text = "Game Language: %s" % (game_language if game_language else "Unknown")
	
	var is_on_steam_deck: bool = Steam.isSteamRunningOnSteamDeck()
	steam_deck_label.text = "Steam Deck: %s" % ("Yes" if is_on_steam_deck else "No")

# Fallback UI for when Steam is not available
func update_ui_offline() -> void:
	name_label.text = "Player: Not connected"
	avatar_texture.texture = placeholder_texture
	steam_id_label.text = "Steam ID: N/A"
	online_status_label.text = "Status: Offline"
	ownership_label.text = "Game Owned: N/A"
	language_label.text = "Game Language: N/A"
	steam_deck_label.text = "Steam Deck: N/A"

# Convert persona state to readable string
func persona_state_to_string(state: int) -> String:
	match state:
		0: return "Offline"
		1: return "Online"
		2: return "Busy"
		3: return "Away"
		4: return "Snooze"
		5: return "Looking to Trade"
		6: return "Looking to Play"
		_: return "Unknown"

# Load and set the Steam avatar
func load_steam_avatar(steam_id: int) -> void:
	# Request user information to ensure avatar is cached
	Steam.requestUserInformation(steam_id, false)
	
	# Connect to avatar_loaded signal (one-shot)
	Steam.connect("avatar_loaded", _on_avatar_loaded.bind(steam_id), CONNECT_ONE_SHOT)

func _on_avatar_loaded(loaded_steam_id: int, size: int, avatar_id: int, steam_id: int) -> void:
	if loaded_steam_id != steam_id:
		avatar_texture.texture = placeholder_texture
		push_warning("Avatar loaded for wrong Steam ID: %d" % loaded_steam_id)
		return
	
	print("Avatar ID: ", avatar_id)
	if avatar_id <= 0:
		avatar_texture.texture = placeholder_texture
		push_warning("Failed to retrieve avatar ID for Steam ID: %d" % steam_id)
		return
	
	# Get avatar image data
	var avatar_data: Dictionary = Steam.getImageRGBA(avatar_id)
	print("Avatar data: ", avatar_data)
	if not avatar_data or not avatar_data.has("width") or not avatar_data.has("height") or not avatar_data.has("buffer"):
		avatar_texture.texture = placeholder_texture
		push_warning("Invalid or empty avatar data for Steam ID: %d" % steam_id)
		return
	
	# Verify buffer is valid
	var width: int = avatar_data.width
	var height: int = avatar_data.height
	var buffer: PackedByteArray = avatar_data.buffer
	print("Buffer size: ", buffer.size() if buffer else 0)
	if width <= 0 or height <= 0 or buffer.is_empty():
		avatar_texture.texture = placeholder_texture
		push_warning("Invalid avatar dimensions or empty buffer for Steam ID: %d" % steam_id)
		return
	
	# Create Image and Texture
	var image := Image.create_from_data(width, height, false, Image.FORMAT_RGBA8, buffer)
	if image.is_empty():
		avatar_texture.texture = placeholder_texture
		push_warning("Failed to create image from avatar data for Steam ID: %d" % steam_id)
		return
	
	var texture := ImageTexture.create_from_image(image)
	if texture:
		avatar_texture.texture = texture
	else:
		avatar_texture.texture = placeholder_texture
		push_warning("Failed to create texture from image for Steam ID: %d" % steam_id)
