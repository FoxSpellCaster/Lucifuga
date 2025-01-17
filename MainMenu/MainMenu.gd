extends Control

func _ready():
	%Play.pressed.connect(play)

func play():
	get_tree().change_scene_to_file("res://Lobby/lobby.tscn")
	
	
