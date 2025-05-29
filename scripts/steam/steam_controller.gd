extends Node

var achievements : Dictionary = {
	"ACH_WIN_ONE_GAME": false,
	"ACH_WIN_100_GAMES": false,
	"ACH_TRAVEL_FAR_ACCUM": false,
	"ACH_TRAVEL_FAR_SINGLE": false
}

func _init():
	#var response : Dictionary = Steam.steamInitEx(3673440, true)
	var response : Dictionary = Steam.steamInitEx(3673440, true)
	print("Connection to Steam")
	print(response)
	
	var username : String = Steam.getPersonaName()
	print("Persona " + username)
	
	var steam_id : int = Steam.getSteamID()
	print("Steam_ID ", steam_id)
	
	Steam.user_stats_received.connect(_user_stats_recived)
	Steam.requestUserStats(steam_id)

func _process (delta):
	Steam.run_callbacks()

func _user_stats_recived(game_id : int, result : int, user_id : int):
	if result != Steam.RESULT_OK:
		print("Unable To Recieve Stats!")
		
	_load_achievements()
	#reset_archievements()
	print("Steam Archievements")
	print(achievements)

func _load_achievements ():
	for a in achievements.keys():
		var steam_ach : Dictionary = Steam.getAchievement(a)
		achievements[a] = steam_ach["achieved"]

func set_achievement (achievement : String):
	achievements[achievement] = true
	
	if not Steam.setAchievement(achievement):
		print("Failed to set archievement: " + achievement)
	
	if not Steam.storeStats():
		print("Failed to store data on Steam.")
	
func reset_archievements ():
	for a in achievements.keys():
		Steam.clearAchievement(a)
