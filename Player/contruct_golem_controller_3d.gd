extends CharacterBody3D

# Movement variables
@export var speed = 5.0
@export var run_speed = 8.0
@export var roll_speed = 12.0
@export var gravity = 20.0
@export var jump_strength = 10.0
@export var mouse_sensitivity = 0.005

# State variables
var is_rolling = false
var is_attacking = false
var is_defending = false
var is_jumping = false
var direction = Vector3.ZERO

# Node references
@onready var camera = $CameraPivot/SpringArm3D/Camera3D
@onready var model = $Model
@onready var anim_player = $Model/AnimationPlayer
@onready var camera_pivot = $CameraPivot
#BUG spring arm length stuff is not where it should be? Grok is helping
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.spring_length = 5.0

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if not is_rolling and not is_attacking:
		handle_movement(delta)
		handle_defense()
	
	move_and_slide()
	
	if direction.length() > 0 and not is_defending:
		var look_dir = atan2(-direction.x, -direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, look_dir, 10.0 * delta)

func handle_movement(_delta):
	var input_dir = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()
	
	direction = Vector3.ZERO
	if input_dir.length() > 0:
		var cam_basis = camera.global_transform.basis
		direction = (cam_basis.z * input_dir.y + cam_basis.x * input_dir.x).normalized()
		direction.y = 0
	
	var current_speed = run_speed if Input.is_action_pressed("run") else speed
	
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_jumping:
		start_jump()
	
	if Input.is_action_just_pressed("action") and direction.length() > 0 and is_on_floor() and not is_jumping:
		start_roll()
		return
	
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed
	
	if is_on_floor():
		if direction.length() > 0:
			anim_player.play("Run")
		else:
			anim_player.play("Idle")

func start_jump():
	is_jumping = true
	velocity.y = jump_strength
	anim_player.play("Jump")
	await get_tree().create_timer(0.1).timeout
	is_jumping = false

func start_roll():
	is_rolling = true
	velocity = direction * roll_speed
	velocity.y = 0
	anim_player.play("Roll")
	await anim_player.animation_finished
	is_rolling = false

func handle_defense():
	if Input.is_action_pressed("defend") and is_on_floor():
		is_defending = true
		velocity.x = 0
		velocity.z = 0
		anim_player.play("Shield")
	else:
		is_defending = false
	
	if Input.is_action_just_pressed("attack") and not is_attacking and is_on_floor():
		is_attacking = true
		anim_player.play("SwordAttack")
		await anim_player.animation_finished
		is_attacking = false

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		$CameraPivot/SpringArm3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$CameraPivot/SpringArm3D.rotation.x = clamp($CameraPivot/SpringArm3D.rotation.x, -1.5, 1.5)
	
	if event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_RIGHT_X:
			camera_pivot.rotate_y(-event.axis_value * 0.05)
		if event.axis == JOY_AXIS_RIGHT_Y:
			$CameraPivot/SpringArm3D.spring_length = clamp(
				$CameraPivot/SpringArm3D.spring_length + event.axis_value * 0.1, 2.0, 8.0
			)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			$CameraPivot/SpringArm3D.spring_length = clamp($CameraPivot/SpringArm3D.spring_length - 0.5, 2.0, 8.0)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			$CameraPivot/SpringArm3D.spring_length = clamp($CameraPivot/SpringArm3D.spring_length + 0.5, 2.0, 8.0)
	
	if Input.is_action_pressed("lock_on"):
		pass
	
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED)
