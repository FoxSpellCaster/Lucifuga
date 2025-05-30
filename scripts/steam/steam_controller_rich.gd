extends Node

var achievements: Dictionary = {
	"LOCATION_HUB": false,
	"STAT_FULL_HEALTH": false,
	"STAT_FULL_BATTERY": false
}

func _init():
	# Initialize Steam
	var response: Dictionary = Steam.steamInitEx(3673440, true)
	print_rich("[b][color=green]🚀 Steam Connection[/color][/b]")
	if response["status"] == 0:
		print_rich("[color=green]✅ Successfully connected to Steam![/color]")
	else:
		print_rich("[color=red]❌ Failed to connect to Steam: [/color][color=yellow]%s[/color]" % response)
	
	# Display user info
	var username: String = Steam.getPersonaName()
	print_rich("[b][color=cyan]👤 Persona:[/color][/b] [color=white]%s[/color]" % username)
	
	var steam_id: int = Steam.getSteamID()
	print_rich("[b][color=cyan]🆔 Steam ID:[/color][/b] [color=white]%d[/color]" % steam_id)
	
	# Connect stats callback
	Steam.user_stats_received.connect(_user_stats_recived)
	Steam.requestUserStats(steam_id)

func _process(delta):
	Steam.run_callbacks()

func _user_stats_recived(game_id: int, result: int, user_id: int):
	if result != Steam.RESULT_OK:
		print_rich("[color=red]❌ Unable to receive stats! Result: [/color][color=yellow]%d[/color]" % result)
		return
	
	_load_achievements()
	#reset_archievements()
	print_rich("\n[b][color=purple]🏆 Steam Achievements[/color][/b]")
	for a in achievements.keys():
		var status = "[color=green]Unlocked[/color]" if achievements[a] else "[color=red]Locked[/color]"
		print_rich("[color=cyan]• %s:[/color] %s" % [a, status])

func _load_achievements():
	for a in achievements.keys():
		var steam_ach: Dictionary = Steam.getAchievement(a)
		achievements[a] = steam_ach["achieved"]

func set_achievement(achievement: String):
	achievements[achievement] = true
	
	if not Steam.setAchievement(achievement):
		print_rich("[color=red]❌ Failed to set achievement: [/color][color=yellow]%s[/color]" % achievement)
	else:
		print_rich("[color=green]✅ Achievement set: [/color][color=cyan]%s[/color]" % achievement)
	
	if not Steam.storeStats():
		print_rich("[color=red]❌ Failed to store stats on Steam![/color]")
	else:
		print_rich("[color=green]✅ Stats stored successfully![/color]")

func reset_archievements():
	print_rich("[b][color=orange]🔄 Resetting Achievements[/color][/b]")
	for a in achievements.keys():
		if Steam.clearAchievement(a):
			print_rich("[color=green]✅ Cleared achievement: [/color][color=cyan]%s[/color]" % a)
		else:
			print_rich("[color=red]❌ Failed to clear achievement: [/color][color=yellow]%s[/color]" % a)
