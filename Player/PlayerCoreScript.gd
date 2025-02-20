extends RigidBody3D
## https://youtu.be/_7riD3FaZgI?si=bsR6Pz2DvnJJKYRo
#TODO Needs Mouse Camera

@export var rolling_force = 40
@export var jump_impulse = 1000

func _ready():
	$BallCameraMarker3D.top_level = true
	$FloorCheckRayCast3D.top_level = true

func _physics_process(delta):
	var old_camera_pos = $BallCameraMarker3D.global_transform.origin
	var ball_pos = global_transform.origin
	var new_camera_pos = lerp(old_camera_pos, ball_pos, 0.1)
	$BallCameraMarker3D.global_transform.origin = new_camera_pos
	
	$FloorCheckRayCast3D.global_transform.origin = global_transform.origin
	
	if Input.is_action_pressed("forward"):
		angular_velocity.x -= rolling_force * delta
	elif Input.is_action_pressed("back"):
		angular_velocity.x += rolling_force * delta
	if Input.is_action_pressed("left"):
		angular_velocity.z += rolling_force * delta
	elif Input.is_action_pressed("right"):
		angular_velocity.z -= rolling_force * delta
	
	#BUG Fixed jumping by adding in a *30, but it still can do an odd double jump
	var is_on_floor = $FloorCheckRayCast3D.is_colliding()
	if Input.is_action_just_pressed("jump") and is_on_floor:
			apply_central_force(Vector3.UP * jump_impulse * 30)
			print("PlayerCore JUMP!")
