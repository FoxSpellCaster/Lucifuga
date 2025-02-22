extends Label

# Export variables to tweak in the inspector
@export var update_interval: float = 0.5  # How often to update in seconds
@export var prefix: String = "FPS: "

# Internal variables
var time_since_update: float = 0.0
var cached_fps: float = 0.0  # Changed to float

func _ready():
	# Optional: Set initial text
	text = prefix + "0"

func _process(delta):
	time_since_update += delta
	
	# Only update FPS display at specified interval to make it more readable
	if time_since_update >= update_interval:
		cached_fps = Engine.get_frames_per_second()  # No conversion needed
		text = prefix + str(cached_fps)
		time_since_update = 0.0
