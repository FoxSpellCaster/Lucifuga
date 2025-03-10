extends CharacterBody3D

# Movement variables
@export_group("Movement")
@export var speed := 5.0
@export var jump_velocity := 4.5
@export var gravity := 9.8
@export var mouse_sensitivity := 0.002

# Nodes
@onready var camera := $Camera3D  # Ensure Camera3D is a child node

func _ready():
	# Capture the mouse initially
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	# Get input direction with inverted forward/backward
	var input_dir := Input.get_vector("move_left", "move_right", "move_backward", "move_forward").normalized()  # back/forward inverted

	# Explicitly define direction, inverting left/right to correct it
	var direction := Vector3.ZERO
	direction.x = -input_dir.x  # Invert left/right: left (+x) becomes -x, right (-x) becomes +x
	direction.z = input_dir.y   # Forward/backward from inverted input (back = +z, forward = -z)
	direction = (transform.basis * direction).normalized()  # Align with character rotation

	# Apply movement
	if direction:
		velocity.x = direction.x * speed  # Left/right now correct
		velocity.z = direction.z * speed  # Forward/backward inverted
	else:
		# Smoothly stop when no input
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# Move the character with Jolt physics
	move_and_slide()

func _input(event: InputEvent) -> void:
	# Mouse look with inverted up/down
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)  # Horizontal look (yaw, unchanged)
		camera.rotate_x(event.relative.y * mouse_sensitivity)  # Vertical look (pitch, inverted)
		camera.rotation.x = clamp(camera.rotation.x, -deg_to_rad(89), deg_to_rad(89))  # Limit pitch

	# Toggle mouse capture with Escape
	if event.is_action_pressed("exit"):  # "ui_cancel" is typically Escape
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
