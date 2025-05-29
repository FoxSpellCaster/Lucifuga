extends Node

func _init():
	var response : Dictionary = Steam.steamInitEx(3673440, true)
	print("Connection to Lucifuga ", response)
	
	var username : String = Steam.getPersonaName()
	print("Persona: ",username)
	
	var steam_id : int = Steam.getSteamID()
	print("Steam_ID ",steam_id)
