extends RigidBody3D

# Movement variables
var speed = 8.0
var acceleration = 500.0
var air_acceleration = 200.0
var jump_force = 400.0
var gravity = 9.8
var direction = Vector3.ZERO
var input_dir = Vector2.ZERO

# Camera mode
var is_first_person = false
@onready var fp_camera = $FirstPersonCamera
@onready var tp_camera = $CameraPivot/ThirdPersonCamera  # Fixed path

func _ready():
	mass = 80.0
	print("fp_camera: ", fp_camera)
	print("tp_camera: ", tp_camera)
	if fp_camera:
		fp_camera.current = is_first_person
	else:
		print("Error: FirstPersonCamera not found!")
	if tp_camera:
		tp_camera.current = !is_first_person
	else:
		print("Error: ThirdPersonCamera not found!")
	fp_camera.position.y = 1.8 - 0.4
	angular_damp = 10.0
	lock_rotation = false

func _physics_process(delta):
	input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	var active_camera = fp_camera if is_first_person else tp_camera
	var cam_forward = -active_camera.global_transform.basis.z.normalized()
	var cam_right = active_camera.global_transform.basis.x.normalized()
	direction = (cam_forward * input_dir.y + cam_right * input_dir.x).normalized()
	
	var is_grounded = linear_velocity.y < 0.1 and linear_velocity.y > -0.1 and get_colliding_bodies().size() > 0
	
	var velocity_horizontal = Vector3(linear_velocity.x, 0, linear_velocity.z)
	var target_velocity = direction * speed
	var accel = acceleration if is_grounded else air_acceleration
	var force = (target_velocity - velocity_horizontal) * mass * accel * delta
	apply_central_force(Vector3(force.x, 0, force.z))
	
	if is_grounded and Input.is_action_just_pressed("ui_jump"):
		apply_central_impulse(Vector3(0, jump_force, 0))
	if Input.is_action_pressed("ui_jump") and linear_velocity.y > 0:
		apply_central_force(Vector3(0, 50.0, 0) * delta)
	
	if direction.length() > 0.1 and is_grounded and not is_first_person:
		var look_dir = Vector2(direction.z, direction.x)
		var target_rotation = look_dir.angle()
		var current_rotation = rotation.y
		var torque = (target_rotation - current_rotation) * 1000.0 * delta
		apply_torque_impulse(Vector3(0, torque, 0))

func _input(event):
	if event.is_action_pressed("toggle_camera"):
		is_first_person = !is_first_person
		if fp_camera:
			fp_camera.current = is_first_person
		if tp_camera:
			tp_camera.current = !is_first_person
		if is_first_person:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if is_first_person and event is InputEventMouseMotion:
		rotation.y -= event.relative.x * 0.005
		fp_camera.rotation.x = clamp(fp_camera.rotation.x - event.relative.y * 0.005, -1.5, 1.5)
