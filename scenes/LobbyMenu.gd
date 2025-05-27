extends Control

@onready var lobby_name_generator = $LobbyNameGenerator
@onready var generate_name_button = $GenerateNameButton
@onready var lobby_name_label = $LobbyNameLabel

func _ready():
	# Connect the button's pressed signal
	generate_name_button.pressed.connect(_on_generate_name_button_pressed)
	# Set initial label text
	lobby_name_label.text = "Lobby: None"

func _on_generate_name_button_pressed():
	# Generate a lobby name
	var lobby_name = lobby_name_generator.generate_constrained_lobby_name(32)
	# Update the UI label
	lobby_name_label.text = "Lobby: " + lobby_name
	# Print to console for debugging
	print("Generated lobby name: ", lobby_name)
