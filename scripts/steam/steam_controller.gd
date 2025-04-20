extends Node

# Export variable for Steam App ID to make it configurable in the editor
@export var steam_app_id: int = 3673440  # Default to Lucifuga's App ID
@export var enable_steam: bool = true  # Toggle Steam integration for testing

func _ready() -> void:
	# Initialize Steam only if enabled
	if not enable_steam:
		print("Steam integration disabled.")
		return
	
	# Initialize Steamworks
	var response: Dictionary = Steam.steamInitEx(steam_app_id, true)
	if response["status"] != 0:
		push_error("Failed to initialize Steam: ", response)
		return
	
	# Retrieve and log user information
	var username: String = Steam.getPersonaName()
	print("Username: ", username if username else "Unknown")
	
	var steam_id: int = Steam.getSteamID()
	print("Steam ID: ", steam_id)
	
	var is_owned: bool = Steam.isSubscribed()
	print("Do you own this game? ", is_owned)
	
	var is_online: bool = Steam.loggedOn()
	print("Steam online: ", is_online)
	
	var launch_cmd_line: String = Steam.getLaunchCommandLine()
	if launch_cmd_line:
		print("Launch command line: ", launch_cmd_line)
	
	var is_on_steam_deck: bool = Steam.isSteamRunningOnSteamDeck()
	print("Running on Steam Deck: ", is_on_steam_deck)
	
	var is_on_vr: bool = Steam.isSteamRunningInVR()
	print("Running in VR: ", is_on_vr)
	
	var is_vac_banned: bool = Steam.isVACBanned()
	if is_vac_banned:
		print("WARNING: Player is VAC banned!")
	
	var game_language: String = Steam.getCurrentGameLanguage()
	print("Game language: ", game_language)
	
	var ui_language: String = Steam.getSteamUILanguage()
	print("UI language: ", ui_language)

# Optional: Clean up Steam when the node is removed
func _exit_tree() -> void:
	if enable_steam:
		Steam.steamShutdown()
		print("Steam shutdown.")
