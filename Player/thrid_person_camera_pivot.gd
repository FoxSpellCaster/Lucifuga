extends Node3D

@export var distance = 5.0
@export var height = 2.0
@export var sensitivity = 0.005

var yaw = 0.0
var pitch = 0.2
@onready var player = get_parent()  # Changed from "../Player" to get_parent()

func _ready():
	update_camera()
	print("Player from CameraPivot: ", player)  # Debug to confirm

func _input(event):
	if not player.is_first_person and event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= event.relative.x * sensitivity
		pitch = clamp(pitch - event.relative.y * sensitivity, -0.5, 0.5)

func _process(delta):
	global_transform.origin = player.global_transform.origin
	update_camera()

func update_camera():
	var cam_pos = Vector3(
		sin(yaw) * cos(pitch) * distance,
		sin(pitch) * distance + height,
		cos(yaw) * cos(pitch) * distance
	)
	$ThirdPersonCamera.global_transform.origin = global_transform.origin + cam_pos
	$ThirdPersonCamera.look_at(global_transform.origin, Vector3.UP)
