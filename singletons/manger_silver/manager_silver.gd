# ref https://youtu.be/rznJhx8xa18?si=Mjjdxoo3KbLaBpd9
# by FoxSpellCaster

class_name ManagerSilver
extends Node

static var reg: ManagerSilver

func _init() -> void:
	if not ref : ref = self
	else : queue_free()


var _silver : int = 0


func get_silver() -> int :
	return _silver


func create_silver(quanity : int) -> void :
	_silver += quantity
# https://youtu.be/rznJhx8xa18?si=6-uR0ffUXlJvwTCg&t=1162
