extends CharacterBody3D

# Movement variables
@export var speed = 5.0
@export var run_speed = 8.0
@export var roll_speed = 12.0
@export var gravity = 20.0
@export var jump_strength = 10.0
@export var mouse_sensitivity = 0.005
@export var dodge_roll_duration = 0.8  # Adjustable roll duration in seconds

# State variables
var is_rolling = false
var is_defending = false
var is_jumping = false
var direction = Vector3.ZERO
var is_running = false  # Added for debug tracking

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

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if not is_rolling:
		handle_movement(delta)
		handle_defense()
	
	move_and_slide()
	
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
	var current_speed = is_running ? run_speed : speed
	print("Running: ", is_running)  # Debug for running
	
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_jumping:
		start_jump()
	
	if Input.is_action_just_pressed("dodge_roll") and direction.length() > 0 and is_on_floor() and not is_jumping:
		start_dodge_roll()
		return
	
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

func start_jump():
	is_jumping = true
	velocity.y = jump_strength
	print("Jump started")  # Debug for jumping
	await get_tree().create_timer(0.1).timeout
	is_jumping = false
	print("Jump ended")  # Debug for jumping end

func start_dodge_roll():
	is_rolling = true
	velocity = direction * roll_speed
	velocity.y = 0
	print("Dodge roll started, waiting ", dodge_roll_duration, "s...")
	await get_tree().create_timer(dodge_roll_duration).timeout
	print("Dodge roll ended")
	velocity.x = 0
	velocity.z = 0
	is_rolling = false

func handle_defense():
	if Input.is_action_pressed("defend") and is_on_floor():
		is_defending = true
		velocity.x = 0
		velocity.z = 0
		print("Defending started")  # Debug for defending
	else:
		if is_defending:
			print("Defending ended")  # Debug for defending end
		is_defending = false

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
		print("Mouse mode toggled to: ", new_mode)  # Debug for mouse capture toggle
