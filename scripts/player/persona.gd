extends Control

# UI nodes for displaying Steam user information
@onready var name_label: Label = $VBoxContainer2/ConnectionContainer/MarginContainer/VBoxContainer/HBoxContainer2/NameLabel
@onready var steam_id_label: Label = $VBoxContainer2/ConnectionContainer/MarginContainer/VBoxContainer/HBoxContainer2/SteamIDLabel
@onready var online_status_label: Label = $VBoxContainer2/ConnectionContainer/MarginContainer/VBoxContainer/HBoxContainer/OnlineStatusLabel

# Called when the node is ready
func _ready() -> void:
	# Check if Steam is initialized and enabled
	if not SteamController or not SteamController.enable_steam or not Steam.isSteamRunning():
		update_ui_offline()
		return
	
	# Verify UI nodes exist
	if not name_label or not steam_id_label or not online_status_label:
		push_error("One or more UI nodes (NameLabel, SteamIDLabel, OnlineStatusLabel) not found")
		update_ui_offline()
		return
	
	# Fetch Steam username
	var username: String = Steam.getPersonaName()
	name_label.text = username if username else "Unknown"
	
	# Fetch Steam ID
	var steam_id: int = Steam.getSteamID()
	steam_id_label.text = "%d" % steam_id
	
	# Fetch online status
	var is_online: bool = Steam.loggedOn()
	var persona_state: int = Steam.getFriendPersonaState(steam_id) if is_online and steam_id else 0
	online_status_label.text = "%s" % persona_state_to_string(persona_state)
	
	# Print debug information
	print("Username: ", username)
	print("Steam ID: ", steam_id)
	print("Online Status: ", persona_state_to_string(persona_state))

# Updates the UI when Steam is not available
func update_ui_offline() -> void:
	if name_label:
		name_label.text = "Offline"
	if steam_id_label:
		steam_id_label.text = "Steam ID: N/A"
	if online_status_label:
		online_status_label.text = "Status: Offline"
	print("Steam offline or not initialized")

# Converts Steam persona state to a readable string
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
