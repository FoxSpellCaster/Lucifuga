extends RigidBody3D

# Movement parameters (adjusted for 80kg mass)
@export var speed := 8.0
@export var sprint_speed := 12.0
@export var acceleration := 20.0
@export var jump_force := 12.0
@export var gravity := 9.8
@export var air_control := 0.3
@export var slide_speed := 12.0
@export var long_jump_multiplier := 1.5

# Triple jump parameters
@export var triple_jump_heights := [12.0, 14.0, 17.0]
var jump_count := 0
var jump_timer := 0.0
const JUMP_WINDOW := 0.2

# Wall slide parameters
@export var wall_slide_speed := 2.0
var is_wall_sliding := false

# Slide parameters
var is_sliding := false
var slide_direction := Vector3.ZERO

# State tracking
var is_grounded := false
var last_velocity := Vector3.ZERO
var is_sprinting := false

# Animation
@onready var anim_player = $'3DGodotRobot/AnimationPlayer'

func _ready():
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true
	
	if not anim_player:
		print("Error: AnimationPlayer not found!")

func _physics_process(delta):
	is_grounded = is_on_floor()
	
	if not is_grounded and not is_wall_sliding:
		apply_central_force(Vector3.DOWN * gravity * mass)
	
	handle_movement(delta)
	
	if jump_timer > 0:
		jump_timer -= delta
	
	if is_grounded and jump_count > 0 and jump_timer <= 0:
		jump_count = 0
	
	update_animations()
	
	# Debug: Print current velocity
	print("Linear Velocity: ", linear_velocity)

func handle_movement(delta: float) -> void:
	var input_dir := Vector3.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.z = Input.get_axis("move_up", "move_down")
	input_dir = input_dir.normalized()
	
	# Debug: Print individual axis values
	print("Move Left: ", Input.is_action_pressed("move_left"))
	print("Move Right: ", Input.is_action_pressed("move_right"))
	print("Move Up: ", Input.is_action_pressed("move_up"))
	print("Move Down: ", Input.is_action_pressed("move_down"))
	print("Input Direction: ", input_dir)
	
	var camera = get_node_or_null("../SpringArm3D/Camera3D")
	if camera:
		var cam_transform = camera.global_transform
		var forward = -cam_transform.basis.z
		var right = cam_transform.basis.x
		forward.y = 0
		right.y = 0
		forward = forward.normalized()
		right = right.normalized()
		input_dir = (forward * input_dir.z + right * input_dir.x).normalized()
	
	# Sprint toggle
	is_sprinting = Input.is_action_pressed("sprint")
	var current_speed = sprint_speed if is_sprinting else speed
	
	if is_grounded and not is_sliding:
		var target_velocity = input_dir * current_speed
		var current_velocity = Vector3(linear_velocity.x, 0, linear_velocity.z)
		var new_velocity = current_velocity.lerp(target_velocity, acceleration * delta)
		linear_velocity.x = new_velocity.x
		linear_velocity.z = new_velocity.z
		
		if Input.is_action_just_pressed("jump"):
			handle_jump()
		
		if Input.is_action_just_pressed("jump") and input_dir.length() > 0.5:
			handle_long_jump(input_dir)
		
		if Input.is_action_just_pressed("move_down") and linear_velocity.length() > speed * 0.8:
			start_slide(input_dir)
		
		if Input.is_action_just_pressed("attack"):
			anim_player.play("Kick")
	
	if not is_grounded and not is_wall_sliding:
		var air_velocity = Vector3(linear_velocity.x, 0, linear_velocity.z)
		air_velocity += input_dir * current_speed * air_control * delta
		air_velocity = air_velocity.limit_length(current_speed)
		linear_velocity.x = air_velocity.x
		linear_velocity.z = air_velocity.z
	
	is_wall_sliding = check_wall_slide(input_dir)
	if is_wall_sliding:
		linear_velocity.y = -wall_slide_speed
		if Input.is_action_just_pressed("jump"):
			handle_wall_jump(input_dir)
	
	if is_sliding:
		linear_velocity = slide_direction * slide_speed
		slide_speed = lerp(slide_speed, 0.0, 2.0 * delta)
		if slide_speed < 1.0:
			stop_slide()

func handle_jump() -> void:
	if jump_count < 3 and (is_grounded or jump_timer > 0):
		linear_velocity.y = triple_jump_heights[jump_count]
		match jump_count:
			0: anim_player.play("Jump")
			1: anim_player.play("Jump2")
			2: anim_player.play("Jump3")
		jump_count += 1
		jump_timer = JUMP_WINDOW

func handle_long_jump(direction: Vector3) -> void:
	if is_grounded:
		linear_velocity.y = jump_force
		linear_velocity += direction * speed * long_jump_multiplier
		jump_count = 1
		anim_player.play("LongJump")

func start_slide(direction: Vector3) -> void:
	is_sliding = true
	slide_direction = direction
	slide_speed = slide_speed
	anim_player.play("GroundSlide")

func stop_slide() -> void:
	is_sliding = false
	slide_direction = Vector3.ZERO

func check_wall_slide(input_dir: Vector3) -> bool:
	if not is_grounded and linear_velocity.y < 0:
		var space_state = get_world_3d().direct_space_state
		var origin = global_transform.origin
		var wall_check_distance = 0.45
		
		var query = PhysicsRayQueryParameters3D.create(
			origin,
			origin + input_dir * wall_check_distance,
			collision_mask
		)
		var result = space_state.intersect_ray(query)
		
		if result and result.normal.dot(Vector3.UP) < 0.1:
			return true
	return false

func handle_wall_jump(input_dir: Vector3) -> void:
	var space_state = get_world_3d().direct_space_state
	var origin = global_transform.origin
	var wall_check_distance = 0.45
	
	var query = PhysicsRayQueryParameters3D.create(
		origin,
		origin + input_dir * wall_check_distance,
		collision_mask
	)
	var result = space_state.intersect_ray(query)
	
	if result and result.normal.dot(Vector3.UP) < 0.1:
		linear_velocity.y = jump_force
		linear_velocity += result.normal * speed
		is_wall_sliding = false
		anim_player.play("WallJump")

func is_on_floor() -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_transform.origin + Vector3(0, 0.1, 0),
		global_transform.origin + Vector3(0, -1.0, 0),
		collision_mask
	)
	var result = space_state.intersect_ray(query)
	return result.size() > 0

func update_animations() -> void:
	if not anim_player.is_playing() or anim_player.current_animation in ["Idle", "Run", "Sprint", "Fall", "Fall2", "WallSlide"]:
		if is_grounded:
			if is_sliding:
				if anim_player.current_animation != "GroundSlide":
					anim_player.play("GroundSlide")
			elif linear_velocity.length() > sprint_speed * 0.8 and is_sprinting:
				anim_player.play("Sprint")
			elif linear_velocity.length() > 0.1:
				anim_player.play("Run")
			else:
				anim_player.play("Idle")
		else:
			if is_wall_sliding:
				anim_player.play("WallSlide")
			elif linear_velocity.y < -5.0:
				anim_player.play("Fall2")
			elif linear_velocity.y < 0:
				anim_player.play("Fall")
