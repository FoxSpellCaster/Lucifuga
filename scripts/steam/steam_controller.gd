extends Node

func _init():
	# Connects to 480 Space War for testing, 3673440 is Lucifuga
	var response : Dictionary = Steam.steamInitEx(3673440, true)
	
	# returns player's NAME
	var username : String = Steam.getPersonaName()
	print(username)
	
	# returns player's ID
	var steam_id : int = Steam.getSteamID()
	print(steam_id)
	
	# do we own this game on Steam?
	var is_owned : bool = Steam.isSubscribed()
	print(is_owned)
	
	# are we logged into Steam?
	var is_online : bool = Steam.loggedOn()
	
	# returns the game's launch options
	var launch_cmd_line : String = Steam.getLaunchCommandLine()
	
	# is the game running on a Steam Deck?
	var is_on_steam_deck : bool = Steam.isSteamRunningOnSteamDeck()
	
	# is the game running in VR?
	var is_on_vr: bool = Steam.isSteamRunningInVR()
	
	# is the player VAC banned?
	var is_vac_banned : bool = Steam.isVACBanned()
	
	# language of the game
	var game_language : String = Steam.getCurrentGameLanguage()
	
	# language of the UI
	var ui_language : String = Steam.getSteamUILanguage()
