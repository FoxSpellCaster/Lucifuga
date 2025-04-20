extends Control

func _ready():
	%DevQuitButton.pressed.connect(quit_game)

func quit_game():
	get_tree().quit()
