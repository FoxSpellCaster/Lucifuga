# ref https://youtu.be/16ilIY25HkM?si=4Pe2rjdah117aOxS
# by FoxSpellCaster

class_name Clicker extends Control


@export var label : Label
@export var button : Button
var gold : int = 0


func _ready() -> void :
	_get_nodes()
	_update_label()


func _get_nodes() -> void :
	label = get_node("%Label")
	button = get_node("%Button")


func _generate_gold() -> void :
	gold += 1
	_update_label()


func _update_label() -> void :
	label.text = "Gold : %s" %gold


func _on_button_pressed() -> void :
	_generate_gold()
