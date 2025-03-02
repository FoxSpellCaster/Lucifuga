extends GPUParticles3D

# Particle parameters (exported for adjustment in the Inspector)
@export var base_lifetime = 0.8  # Base particle lifetime in seconds
@export var flicker_speed = 8.0  # How fast particles flicker (Hz, for retro blocky effect)
@export var particle_count = 75  # Number of particles for retro, low-poly look
@export var initial_velocity = 3.0  # Base speed of particles (m/s)
@export var velocity_variation = 1.0  # Max variation in velocity (m/s)
@export var color_hue_shift = 0.05  # Max hue shift for retro color variance (0.0–1.0, blue-teal range)
@export var color_saturation = 0.8  # Base saturation for vibrant blue-teal fire (0.0–1.0)
@export var color_value = 1.0  # Base value/brightness for fire (0.0–1.0)
@export var flicker_interval = 0.1  # Fixed interval for discrete updates (seconds, for blocky effect)

# Internal variables
var time = 0.0
var flicker_timer = 0.0
var process_material: ParticleProcessMaterial
var parent_particles: GPUParticles3D  # Reference to parent BlueFire

func _ready():
	# Get or create the process material
	process_material = particle_process_material as ParticleProcessMaterial
	if process_material == null:
		process_material = ParticleProcessMaterial.new()
		particle_process_material = process_material
	
	# Set initial properties for retro Quake-style blue-teal fire
	amount = particle_count
	lifetime = base_lifetime
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_material.emission_box_extents = Vector3(0.1, 0.1, 0.1)  # Tight emission area
	process_material.direction = Vector3(0, 1, 0)  # Upward
	process_material.spread = 15.0  # Narrow spread for column-like sparks
	process_material.gravity = Vector3(0, -2, 0)  # Slight upward drift for Quake fire
	process_material.initial_velocity_min = initial_velocity - velocity_variation
	process_material.initial_velocity_max = initial_velocity + velocity_variation
	process_material.scale_min = 0.1
	process_material.scale_max = 0.3
	update_particle_color()  # Set initial color
	
	# Get reference to parent BlueFire for synchronization
	parent_particles = get_parent() as GPUParticles3D
	if parent_particles == null:
		push_error("Parent GPUParticles3D (BlueFire) not found. Ensure FireParticles is a child of BlueFire.")

func _physics_process(delta):
	flicker_timer += delta
	
	# Update flicker at fixed intervals for a blocky, retro effect
	if flicker_timer >= flicker_interval:
		flicker_timer = 0.0
		time += 1.0  # Increment for discrete steps
		
		# Sync random value from parent particles for consistent flicker
		var random_value = 0.0
		if parent_particles != null:
			random_value = parent_particles.get_synchronized_random()
		else:
			# Fallback if parent not found (use local random)
			seed(time * flicker_speed)
			random_value = randf()
		
		# Random velocity variation for retro choppiness
		var velocity_noise = lerp(-velocity_variation, velocity_variation, random_value)
		process_material.initial_velocity_min = initial_velocity - velocity_variation + velocity_noise
		process_material.initial_velocity_max = initial_velocity + velocity_variation + velocity_noise
		
		# Random color variation using Light3D color (HSV for blue-teal Quake style)
		var hue = 0.5 + lerp(-color_hue_shift, color_hue_shift, random_value)  # Blue-teal base with synchronized shift
		update_particle_color(hue)

func update_particle_color(hue: float = 0.5):
	# Create a gradient for Quake-style blue-teal fire
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color.from_hsv(hue, color_saturation, color_value))  # Bright blue-teal
	gradient.add_point(1.0, Color.from_hsv(wrapf(hue + 0.05, 0.0, 1.0), color_saturation, 0.0))  # Fade to darker teal
	process_material.color_ramp = gradient

# Optional: Reset on node activation
func _on_tree_entered():
	amount = particle_count
	lifetime = base_lifetime
	update_particle_color()

# Method to sync with parent particles
func sync_flicker(random_value: float):
	# This method can be called by the parent, but we use get_synchronized_random() directly
	time = floor((random_value * flicker_speed) / (2.0 * PI))  # Sync time based on random value
	var velocity_noise = lerp(-velocity_variation, velocity_variation, random_value)
	process_material.initial_velocity_min = initial_velocity - velocity_variation + velocity_noise
	process_material.initial_velocity_max = initial_velocity + velocity_variation + velocity_noise
	
	var hue = 0.5 + lerp(-color_hue_shift, color_hue_shift, random_value)  # Blue-teal base with synchronized shift
	update_particle_color(hue)
