extends Control
@export var next_scene: PackedScene 

func _ready():
	await get_tree().create_timer(2.0).timeout  # Adjust delay as needed
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
