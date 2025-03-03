extends Node3D

@export var target: Node3D # The player to follow
@export var rotation_speed := 5.0 # Mouse sensitivity
@export var vertical_angle_limit := deg_to_rad(80) # Max up/down angle
@export var distance := 5.0 # Max distance from player
@export var collision_mask := 2 # Layer for environment (e.g., Layer 2)

var yaw := 0.0 # Horizontal rotation
var pitch := 0.0 # Vertical rotation
var collision_point := Vector3.ZERO

func _ready():
	if not target:
		target = get_node("../Player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if not target:
		return
	
	# Follow the player's position (y adjusted to stay at ground level or slightly above)
	global_transform.origin = target.global_transform.origin
	global_transform.origin.y += 0.9 # Align with character's center (half of 1.8m height)
	
	# Apply rotation to the pivot
	var new_transform = Basis()
	new_transform = new_transform.rotated(Vector3.UP, yaw)
	new_transform = new_transform.rotated(new_transform.x, pitch)
	basis = new_transform
	
	# Calculate desired camera position
	var desired_position = global_transform.origin + (-basis.z * distance + Vector3(0, 1.8, 0))
	
	# Check for collisions using raycast
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		target.global_transform.origin + Vector3(0, 1.8, 0), # Start at player head height
		desired_position,
		collision_mask
	)
	var result = space_state.intersect_ray(query)
	
	if result:
		collision_point = result.position
		$Camera3D.global_transform.origin = collision_point
	else:
		$Camera3D.global_transform.origin = desired_position

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * rotation_speed * 0.002
		pitch = clamp(
			pitch - event.relative.y * rotation_speed * 0.002,
			-vertical_angle_limit,
			vertical_angle_limit
		)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
