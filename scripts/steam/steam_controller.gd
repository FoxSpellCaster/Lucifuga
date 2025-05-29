extends Node

func _init():
	var response : Dictionary = Steam.steamInitEx(3673440, true)
	print(response)
