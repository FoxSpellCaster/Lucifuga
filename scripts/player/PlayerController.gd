class_name PlayerController
extends CharacterBody3D

@export_group("Movement")
@export var max_speed: float = 4.0
@export var acceleration: float = 20.0
@export var braking: float = 20.0
@export var air_acceleration: float = 4.0
@export var jump_force: float = 5.0
@export var gravity_modifier: float = 1.5
@export var max_run_speed: float = 6.0
var is_running: bool = false

@export_group("Camera")
@export var look_sensitivity: float = 0.003
var camera_look_input: Vector2

@onready var camera: Camera3D = $Camera3D
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_modifier
var player_id: int = 0  # Set to Steam ID for multiplayer

func _ready():
	# Set player ID based on Steam ID or multiplayer ID
	player_id = multiplayer.get_unique_id()  # For Steam, this is the Steam ID
	# Only enable camera for the owning player
	if multiplayer.get_unique_id() == player_id:
		camera.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		# Disable camera for non-owning clients
		camera.current = false

func _physics_process(delta):
	# Only process input and movement for the owning client
	if multiplayer.get_unique_id() == player_id:
		# Apply gravity
		if not is_on_floor():
			velocity.y -= gravity * delta
		
		# Jumping
		if Input.is_action_pressed("jump") and is_on_floor():
			velocity.y = jump_force
		
		# Movement
		var move_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var move_dir = (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
		
		is_running = Input.is_action_pressed("sprint")
		
		var target_speed = max_speed
		
		if is_running:
			target_speed = max_run_speed
			var run_dot = -move_dir.dot(transform.basis.z)
			run_dot = clamp(run_dot, 0.0, 1.0)
			move_dir *= run_dot
		
		var current_smoothing = acceleration
		
		if not is_on_floor():
			current_smoothing = air_acceleration
		elif not move_dir:
			current_smoothing = braking
		
		var target_vel = move_dir * target_speed
		
		velocity.x = lerp(velocity.x, target_vel.x, current_smoothing * delta)
		velocity.z = lerp(velocity.z, target_vel.z, current_smoothing * delta)
		
		move_and_slide()
		
		# Camera Look
		rotate_y(-camera_look_input.x * look_sensitivity)
		camera.rotate_x(-camera_look_input.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)
		camera_look_input = Vector2.ZERO
		
		# Sync position and rotation to other clients
		sync_state.rpc(global_position, velocity, rotation.y, camera.rotation.x)

	# For non-owning clients, position and rotation are updated via RPC
	else:
		move_and_slide()

# RPC to sync player state (position, velocity, rotation)
@rpc("any_peer", "call_remote", "reliable")
func sync_state(pos: Vector3, vel: Vector3, rot_y: float, cam_rot_x: float):
	if multiplayer.get_unique_id() != player_id:
		global_position = pos
		velocity = vel
		rotation.y = rot_y
		camera.rotation.x = cam_rot_x

func _unhandled_input(event):
	# Only process input for the owning client
	if multiplayer.get_unique_id() == player_id:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			camera_look_input = event.relative
		if Input.is_action_just_pressed("ui_cancel"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
