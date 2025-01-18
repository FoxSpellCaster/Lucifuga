extends Control

func _ready():
	%Play.pressed.connect(play)
	%Quit.pressed.connect(quit_game)

#TODO Settings Menu needs to me created and a reverse mouse ignore needs to be added into the node
#BUG: Error calling from signal 'pressed' to callable: 'CenterContainer::set_mouse_filter': Method expected 1 arguments, but called with 0.

func play():
	get_tree().change_scene_to_file("res://Lobby/lobby.tscn")
	
func quit_game():
	get_tree().quit()
