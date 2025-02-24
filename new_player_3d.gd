extends CharacterBody3D

## Third-person character controller with camera, movement, crouching, and sprinting.
## Controls a 3D character with mouse-based camera rotation, WASD movement, jumping,
## crouching toggle, and sprinting. Based on: https://youtu.be/JlgZtOFMdfc?si=4VASxywjJllB8IB8

@export_group("Camera")
## Sensitivity of mouse input for camera rotation (0.0 to 1.0).
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
## Minimum vertical angle for camera rotation in radians (e.g., -0.5 is ~29° downward).
@export_range(-PI/2.0, PI/2.0) var camera_vertical_min := -0.5
## Maximum vertical angle for camera rotation in radians (e.g., 0.5 is ~29° upward).
@export_range(-PI/2.0, PI/2.0) var camera_vertical_max := 0.5

@export_group("Movement")
## Base movement speed when walking (units per second).
@export var walk_speed := 8.0
## Movement speed when sprinting (units per second).
@export var sprint_speed := 12.0
## Movement speed when crouching (units per second).
@export var crouch_speed := 4.0
## Rate of speed change for smooth acceleration (units per second squared).
@export var acceleration := 20.0
## Speed of character model rotation to face movement direction (radians per second).
@export var rotation_speed := 12.0
## Upward velocity applied when jumping (units per second).
@export var jump_impulse := 12.0
## Amount to reduce collision shape height when crouching (units).
@export var crouch_height_reduction := 0.5

## Accumulated mouse input for camera rotation this frame.
var _camera_input := Vector2.ZERO
## Last direction the character moved, used for skin rotation.
var _last_movement_direction := Vector3.FORWARD
## Gravity acceleration from project settings (negative downward, units per second squared).
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") * -1.0
## Tracks whether the character is currently crouching.
var _is_crouching := false
## Original height of the collision shape, stored at startup.
var _default_height: float
## Default Y position of the camera pivot, stored at startup.
var _default_camera_y: float

## Pivot point for camera rotation, typically positioned above the character.
@onready var _camera_pivot: Marker3D = %CameraPivot
## Main camera node for third-person view, attached to SpringArm3D.
@onready var _camera: Camera3D = %Camera3D
## Visual representation of the character (e.g., a mesh).
@onready var _skin: Node3D = %Player3DSkin
## Collision shape defining the character's physical bounds.
@onready var _collision_shape: CollisionShape3D = %CollisionShape3D

## Initializes default height and camera position for crouching mechanics.
func _ready() -> void:
	if _collision_shape.shape is CapsuleShape3D:
		_default_height = _collision_shape.shape.height
	else:
		_default_height = 2.0  # Fallback for non-capsule shapes
	_default_camera_y = _camera_pivot.position.y  # Store initial pivot height

## Handles mouse capture and release input events.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  # Capture mouse for camera control
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("free_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # Release mouse

## Processes unhandled input, specifically mouse motion for camera rotation.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_camera_input = event.screen_relative * mouse_sensitivity  # Accumulate camera input

## Updates physics-based movement and camera each frame.
func _physics_process(delta: float) -> void:
	_update_camera(delta)
	_update_movement(delta)
	_update_skin_rotation(delta)
	move_and_slide()  # Apply movement and collision

## Updates camera rotation based on mouse input, using the SpringArm3D via Marker3D pivot.
func _update_camera(delta: float) -> void:
	_camera_pivot.rotation.x += _camera_input.y * delta  # Vertical rotation (positive up, negative down)
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, camera_vertical_min, camera_vertical_max)
	_camera_pivot.rotation.y -= _camera_input.x * delta  # Horizontal rotation
	_camera_input = Vector2.ZERO  # Reset input after applying

## Updates character movement, including crouching, sprinting, and jumping.
func _update_movement(delta: float) -> void:
	# Toggle crouching state
	if Input.is_action_just_pressed("crouch"):
		_is_crouching = !_is_crouching
		_adjust_crouch_height(delta)

	# Determine speed based on state
	var current_speed := walk_speed
	if _is_crouching:
		current_speed = crouch_speed
	elif Input.is_action_pressed("sprint") and is_on_floor():
		current_speed = sprint_speed

	# Calculate movement direction from camera perspective
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var forward := _camera.global_basis.z  # Camera's forward (-Z)
	var right := _camera.global_basis.x    # Camera's right (+X)
	var move_direction := (forward * raw_input.y + right * raw_input.x).normalized()
	move_direction.y = 0.0  # Keep movement horizontal

	# Apply velocity with acceleration
	var y_velocity := velocity.y
	velocity.y = 0.0  # Preserve vertical velocity separately
	velocity = velocity.move_toward(move_direction * current_speed, acceleration * delta)
	velocity.y = y_velocity + _gravity * delta  # Apply gravity

	# Handle jumping (disabled while crouching)
	if Input.is_action_just_pressed("jump") and is_on_floor() and not _is_crouching:
		velocity.y += jump_impulse

	# Update last movement direction for skin rotation
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction

## Rotates the character model to face the movement direction smoothly.
func _update_skin_rotation(delta: float) -> void:
	var target_angle := Vector3.FORWARD.signed_angle_to(_last_movement_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)

## Adjusts collision shape and camera height when crouching or standing up, with smoothing.
func _adjust_crouch_height(delta: float) -> void:
	if not _collision_shape.shape is CapsuleShape3D:
		return  # Requires a CapsuleShape3D for now
	var shape := _collision_shape.shape as CapsuleShape3D
	var target_height: float
	var target_camera_y: float
	
	if _is_crouching:
		target_height = _default_height - crouch_height_reduction
		target_camera_y = _default_camera_y - crouch_height_reduction / 2.0
	else:
		target_height = _default_height
		target_camera_y = _default_camera_y
	
	# Apply changes with smoothing
	shape.height = lerp(shape.height, target_height, 10.0 * delta)
	_camera_pivot.position.y = lerp(_camera_pivot.position.y, target_camera_y, 10.0 * delta)
