extends Node
class_name MovementController

@export var player : Player
@export var mesh_root : Node3D
@export var rotation_speed : float = 8
@export var fall_gravity : float = 45
var jump_gravity : float = fall_gravity
var direction : Vector3
var velocity : Vector3
var acceleration : float
var speed : float
var cam_rotation : float = 0
var player_init_rotation : float
var dash_timer : Timer
var dash_velocity : Vector3
var tween : Tween


func _ready():
	player_init_rotation = player.rotation.y
	dash_timer = Timer.new()
	dash_timer.one_shot = true
	add_child(dash_timer)


func _physics_process(delta):
	velocity.x = speed * direction.normalized().x
	velocity.z = speed * direction.normalized().z
	
	if is_dashing():
		velocity.x = dash_velocity.x
		velocity.z = dash_velocity.z
	elif player.is_attacking:
		velocity.x = 0
		velocity.z = 0
	else:
		var target_rotation = atan2(direction.x, direction.z) - player_init_rotation
		mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, target_rotation, rotation_speed * delta)

	if not player.is_on_floor():
		if velocity.y >= 0:
			velocity.y -= jump_gravity * delta
		else:
			velocity.y -= fall_gravity * delta
	
	player.velocity = player.velocity.lerp(velocity, acceleration * delta)
	player.move_and_slide()


func dash(_velocity : Vector3, duration : float, delay : float):
	force_rotate_mesh()
	await get_tree().create_timer(delay).timeout
	dash_timer.start(duration)
	var rotation : float = atan2(direction.x, direction.z)
	dash_velocity = _velocity.rotated(Vector3.UP, rotation)


func is_dashing() -> bool:
	return dash_timer.time_left > 0


func force_rotate_mesh():
	if tween:
		tween.kill()

	var target_rotation : Vector3 = mesh_root.rotation
	target_rotation.y = lerp_angle(mesh_root.rotation.y, atan2(direction.x, direction.z) - player_init_rotation, 1)
	
	tween = create_tween()
	tween.tween_property(mesh_root, "rotation", target_rotation, 0.1)


func _jump(jump_state : JumpState):
	if is_dashing():
		return
	
	if player.is_attacking:
		return

	velocity.y = 2 * jump_state.jump_height / jump_state.apex_duration
	jump_gravity = velocity.y / jump_state.apex_duration


func _on_set_movement_state(_movement_state : MovementState):
	if player.is_attacking:
		return
	
	speed = _movement_state.movement_speed
	acceleration =  _movement_state.acceleration


func _on_set_movement_direction(_movement_direction : Vector3):
	if player.is_attacking:
		return
	
	direction = _movement_direction.rotated(Vector3.UP, cam_rotation + player_init_rotation)


func _on_set_cam_rotation(_cam_rotation : float):
	cam_rotation = _cam_rotation
