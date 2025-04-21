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
	var _username: String = Steam.getPersonaName()
	
	var _steam_id: int = Steam.getSteamID()
	
	var _is_owned: bool = Steam.isSubscribed()
	
	var _is_online: bool = Steam.loggedOn()
	
	var _launch_cmd_line: String = Steam.getLaunchCommandLine()
	
	var _is_on_steam_deck: bool = Steam.isSteamRunningOnSteamDeck()
	
	var _is_on_vr: bool = Steam.isSteamRunningInVR()
	
	var _is_vac_banned: bool = Steam.isVACBanned()
	
	var _game_language: String = Steam.getCurrentGameLanguage()
	
	var _ui_language: String = Steam.getSteamUILanguage()

# Optional: Clean up Steam when the node is removed
func _exit_tree() -> void:
	if enable_steam:
		Steam.steamShutdown()
		print("Steam shutdown.")
