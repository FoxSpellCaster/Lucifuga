extends Node2D

func _ready():
	_welcome_message()
	_add(10,25)

func _add(a, b):
	var sum = a + b
	print(sum)

# prints out function message when called
func _welcome_message():
	print ("The function was called!")

func _process(delta):
	pass
