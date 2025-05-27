extends Node3D

func _ready():
	var generator = LobbyNameGenerator.new()
	print(generator.generate_lobby_name()) # e.g., "ShadowMysticHaven"
