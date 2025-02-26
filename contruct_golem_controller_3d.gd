extends CharacterBody3D

# Movement variables
@export var speed = 5.0
@export var run_speed = 8.0
@export var roll_speed = 12.0
@export var gravity = 20.0
@export var jump_strength = 10.0

# State variables
var is_rolling = false
var is_attacking = false
var is_defending = false
var velocity = Vector3.ZERO
var direction = Vector3.ZERO

# Node references
@onready var camera = $CameraPivot/SpringArm3D/Camera3D  # Adjust node path as needed
@onready var model = $Model  # Your Link 3D model node
@onready var anim_player = $AnimationPlayer  # For animations

# Inventory items (simplified)
var equipped_items = {"X": null, "Y": null, "Z": null}

func _ready():
	# Ensure the camera is set up
	camera.spring_length = 5.0  # Distance from player

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle input and states
	if not is_rolling and not is_attacking:
		handle_movement(delta)
		handle_defense()
		handle_items()
	
	# Move the character
	velocity = move_and_slide(velocity, Vector3.UP)
	
	# Update model rotation
	if direction.length() > 0 and not is_defending:
		var look_dir = atan2(-direction.x, -direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, look_dir, 10.0 * delta)

func handle_movement(delta):
	# Input direction from analog stick (or WASD for testing)
	var input_dir = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()
	
	direction = Vector3.ZERO
	if input_dir.length() > 0:
		# Transform direction relative to camera
		var cam_basis = camera.global_transform.basis
		direction = (cam_basis.z * input_dir.y + cam_basis.x * input_dir.x).normalized()
		direction.y = 0
	
	# Speed adjustment
	var current_speed = run_speed if Input.is_action_pressed("run") else speed
	
	# Rolling (A button while moving)
	if Input.is_action_just_pressed("action") and direction.length() > 0 and is_on_floor():
		start_roll()
		return
	
	# Apply horizontal velocity
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed
	
	# Animation (assuming you have "Idle", "Run", "Roll" animations)
	if direction.length() > 0:
		anim_player.play("Run")
	else:
		anim_player.play("Idle")

func start_roll():
	is_rolling = true
	velocity = direction * roll_speed
	anim_player.play("Roll")
	await anim_player.animation_finished
	is_rolling = false

func handle_defense():
	# Shield up with R button
	if Input.is_action_pressed("defend") and is_on_floor():
		is_defending = true
		velocity.x = 0
		velocity.z = 0
		anim_player.play("Shield")
	else:
		is_defending = false

func handle_items():
	# Sword attack (B button)
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		anim_player.play("SwordAttack")
		await anim_player.animation_finished
		is_attacking = false
	
	# Item usage (X, Y, Z buttons)
	if Input.is_action_just_pressed("item_x"):
		use_item("X")
	if Input.is_action_just_pressed("item_y"):
		use_item("Y")
	if Input.is_action_just_pressed("item_z"):
		use_item("Z")

func use_item(slot: String):
	if equipped_items[slot]:
		print("Using item in slot ", slot)  # Replace with actual item logic

func _input(event):
	# Camera control with right stick
	if event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_RIGHT_X:
			$CameraPivot.rotate_y(-event.axis_value * 0.05)
		if event.axis == JOY_AXIS_RIGHT_Y:
			$CameraPivot/SpringArm3D.spring_length = clamp(
				$CameraPivot/SpringArm3D.spring_length + event.axis_value * 0.1, 2.0, 8.0
			)
	
	# L-targeting (lock-on)
	if Input.is_action_pressed("lock_on"):
		# Add logic to lock onto nearest enemy (not implemented here)
		pass
