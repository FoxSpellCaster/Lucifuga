extends OmniLight3D

# Flickering parameters (exported for adjustment in the Inspector)
@export var base_intensity = 1.5  # Lower base intensity for retro look (lumens)
@export var flicker_intensity = 0.5  # Max variation in intensity for retro, blocky flicker
@export var flicker_steps = 3  # Number of discrete intensity levels for retro, blocky flicker
@export var flicker_speed = 8.0  # Faster, choppier flicker for retro style (Hz)
@export var color_hue_shift = 0.05  # Max hue shift for retro color variance (0.0–1.0)
@export var color_saturation = 0.8  # Base saturation for vibrant Quake fire (0.0–1.0)
@export var color_value = 1.0  # Base value/brightness for fire (0.0–1.0)
@export var flicker_interval = 0.1  # Fixed interval for discrete updates (seconds, for blocky effect)

# Internal variables
var time = 0.0
var current_step = 0
var target_intensity = base_intensity
var flicker_timer = 0.0

func _ready():
	# Ensure initial values are set for retro Quake style
	light_energy = base_intensity
	light_color = Color.from_hsv(0.1, color_saturation, color_value)  # Orange base for Quake fire

func _physics_process(delta):
	flicker_timer += delta
	
	# Update flicker at fixed intervals for a blocky, retro effect
	if flicker_timer >= flicker_interval:
		flicker_timer = 0.0
		time += 1.0  # Increment for discrete steps
		
		# Discrete intensity steps for retro flicker
		current_step = (time * flicker_speed) as int % flicker_steps
		var intensity_range = flicker_intensity / (flicker_steps - 1) if flicker_steps > 1 else 0.0
		target_intensity = base_intensity + (current_step - (flicker_steps - 1) / 2.0) * intensity_range
		
		# Random color variation using Light3D color (HSV for Quake style)
		var hue = 0.1 + randf_range(-color_hue_shift, color_hue_shift)  # Orange base with slight shift (0.0–0.2)
		light_color = Color.from_hsv(
			wrapf(hue, 0.0, 1.0),  # Wrap hue to stay in orange-red range
			color_saturation,       # Fixed saturation for vibrant fire
			color_value             # Fixed value for brightness
		)
	
	# Apply values (no smoothing for abrupt, blocky changes)
	light_energy = target_intensity

# Optional: Reset on node activation
func _on_tree_entered():
	light_energy = base_intensity
	light_color = Color.from_hsv(0.1, color_saturation, color_value)
