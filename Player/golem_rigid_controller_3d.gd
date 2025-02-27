extends RigidBody3D

# Movement variables
@export var speed = 5.0
@export var run_speed = 8.0
@export var roll_speed = 12.0  # Base speed, overridden by dodge_roll_distance
@export var gravity = 9.8  # Match Jolt Physics default
@export var jump_strength = 10.0  # Reduced for a lower jump
@export var mouse_sensitivity = 0.005
@export var dodge_roll_duration = 0.8  # Adjustable roll duration in seconds
@export var dodge_roll_distance = 10.0  # Adjustable roll distance in meters

# State variables
var is_rolling = false
var is_defending = false
var is_jumping = false
var direction = Vector3.ZERO
var is_running = false  # Added for debug tracking
var was_running = false  # Track previous running state
var was_defending = false  # Track previous defending state

# Node references
@onready var camera = $CameraPivot/SpringArm3D/Camera3D
@onready var spring_arm = $CameraPivot/SpringArm3D
@onready var model = $Model
@onready var camera_pivot = $CameraPivot

func _ready():
	# Explicit mouse capture on start
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("Mouse captured on start. Mode: ", Input.get_mouse_mode())
	print("Camera: ", camera)
	print("SpringArm: ", spring_arm)
	print("Model: ", model)
	print("CameraPivot: ", camera_pivot)
	if spring_arm != null:
		spring_arm.spring_length = 5.0
	else:
		push_error("SpringArm3D node not found at $CameraPivot/SpringArm3D")
	# Ensure rotation is locked (correct property for RigidBody3D in Godot 4)
	lock_rotation = true

func _physics_process(delta):
	# Apply gravity manually to match Jolt’s 9.8 m/s², scaled by mass
	if not is_on_floor():
		apply_force(Vector3(0, -gravity * mass, 0) * delta)
	
	if not is_rolling:
		handle_movement(delta)
		handle_defense()
	
	# Update rotation (visual only, since rotation is locked)
	if direction.length() > 0 and not is_defending:
		var look_dir = atan2(-direction.x, -direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, look_dir, 10.0 * delta)

func handle_movement(_delta):
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	
	direction = Vector3.ZERO
	if input_dir.length() > 0:
		var cam_basis = camera.global_transform.basis if camera != null else global_transform.basis
		direction = (cam_basis.z * input_dir.y + cam_basis.x * input_dir.x).normalized()
		direction.y = 0
	
	is_running = Input.is_action_pressed("run")
	var current_speed = run_speed if is_running else speed
	
	# Check if running state changed and print only on start/stop
	if is_running != was_running:
		if is_running:
			print("Running started")
		else:
			print("Running stopped")
	was_running = is_running  # Update previous state
	
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_jumping:
		print("On floor: ", is_on_floor())  # Debug to verify floor detection
		start_jump()
	
	if Input.is_action_just_pressed("dodge_roll") and direction.length() > 0 and is_on_floor() and not is_jumping:
		start_dodge_roll()
		return
	
	# Use linear_velocity for precise movement (overrides physics for linear motion)
	if not is_defending and not is_rolling:
		linear_velocity = Vector3(direction.x * current_speed, linear_velocity.y, direction.z * current_speed)

func start_jump():
	is_jumping = true
	linear_velocity = Vector3(linear_velocity.x, jump_strength, linear_velocity.z)
	print("Jump started. Linear Velocity set to: ", linear_velocity)
	# Let physics handle the jump naturally, no timer
	is_jumping = false  # Set immediately, physics will handle duration
	print("Jump ended. Final Linear Velocity: ", linear_velocity)

func start_dodge_roll():
	is_rolling = true
	# Calculate roll_speed based on desired distance and duration
	var calculated_roll_speed = dodge_roll_distance / dodge_roll_duration
	linear_velocity = direction * calculated_roll_speed  # Use linear_velocity for consistent movement
	print("Dodge roll started, waiting ", dodge_roll_duration, "s... Speed: ", calculated_roll_speed)
	await get_tree().create_timer(dodge_roll_duration).timeout
	print("Dodge roll ended")
	linear_velocity = Vector3(0, linear_velocity.y, 0)  # Reset horizontal velocity, keep vertical
	is_rolling = false

func handle_defense():
	var should_defend = Input.is_action_pressed("defend") and is_on_floor()
	
	# Check if defending state changed and print only on start/stop
	if should_defend != was_defending:
		if should_defend:
			print("Defending started")
			# Freeze movement by setting linear velocity to zero (horizontal)
			linear_velocity = Vector3(0, linear_velocity.y, 0)
			freeze = true
		else:
			print("Defending ended")
			freeze = false  # Unfreeze to allow movement again
	
	is_defending = should_defend
	was_defending = is_defending  # Update previous state

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		if spring_arm != null:
			spring_arm.rotate_x(-event.relative.y * mouse_sensitivity)
			spring_arm.rotation.x = clamp(spring_arm.rotation.x, -1.5, 1.5)
	
	if event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_RIGHT_X:
			camera_pivot.rotate_y(-event.axis_value * 0.05)
		if event.axis == JOY_AXIS_RIGHT_Y and spring_arm != null:
			spring_arm.spring_length = clamp(
				spring_arm.spring_length + event.axis_value * 0.1, 2.0, 8.0
			)
	
	if event is InputEventMouseButton and spring_arm != null:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring_arm.spring_length = clamp(spring_arm.spring_length - 0.5, 2.0, 8.0)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring_arm.spring_length = clamp(spring_arm.spring_length + 0.5, 2.0, 8.0)
	
	if event.is_action_pressed("ui_cancel"):
		var new_mode = Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
		Input.mouse_mode = new_mode
		print("Mouse mode toggled to: ", new_mode)

# Helper function to check if on floor (for RigidBody3D)
func is_on_floor() -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = global_transform.origin
	query.to = global_transform.origin + Vector3(0, -1.5, 0)  # Adjust length based on model height
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	return result.size() > 0
