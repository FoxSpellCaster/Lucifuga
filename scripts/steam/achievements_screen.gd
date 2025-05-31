extends Control

@onready var list_container : VBoxContainer = $AchievementList
var boxes : Array = []

func _ready ():
	boxes = list_container.get_children()
	_update_list()
	Steam.user_stats_stored.connect(_on_user_stats_stored)

func _on_user_stats_stored (game_id : int, result :int):
	_update_list()

func _update_list ():
	var achs = SteamController.achievements.keys()
	
	for i in len(boxes):
		if i >= len(achs):
			boxes[i].visible = false
			continue
		
		boxes[i].visible = true
		boxes[i].set_achievement(achs[i])
