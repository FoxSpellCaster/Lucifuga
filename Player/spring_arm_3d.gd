extends SpringArm3D

@export var target: Node3D # The player to follow
@export var rotation_speed := 5.0 # Mouse sensitivity
@export var vertical_angle_limit := deg_to_rad(80) # Max up/down angle

var yaw := 0.0 # Horizontal rotation
var pitch := 0.0 # Vertical rotation

func _ready():
	if not target:
		target = get_node("../Player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Set initial rotation to face forward
	rotation.y = 0

func _process(_delta):
	if not target:
		return
	
	# Follow the player's position
	global_transform.origin = target.global_transform.origin
	
	# Apply rotation to the SpringArm3D
	rotation.y = yaw
	rotation.x = pitch

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
