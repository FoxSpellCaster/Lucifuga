extends Control

func _ready():
	%Play.pressed.connect(play)
	%Quit.pressed.connect(quit_game)

func play():
	get_tree().change_scene_to_file("res://scenes/LoadingScreen.tscn")
	
func quit_game():
	get_tree().quit()
