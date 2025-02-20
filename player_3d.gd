extends CharacterBody3D

@export_group("Camera")
@export_range(0.0,1.0) var mouse_sensitivity := 0.25

var _camera_input_direction := Vector2.ZERO

@onready var _camera_pivot: Marker3D = %CameraPivot
# How we capture the freaking mouse and release it
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

#handeling the mouse being captured by the game
func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	# -PI / 6.0, PI / 3.0 is -30deg and 60deg
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x,-PI / 6.0, PI / 3.0)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta

#stop camera from rotating
	_camera_input_direction = Vector2.ZERO
