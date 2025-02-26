extends PanelContainer

@onready var property_container = %VBoxContainer

#var property
var frames_per_second : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Set global reference to self in Global Singleton
	Global.debug = self

	# Hide Debug Panel on load
	visible = false

	#add_debug_property("FPS", frames_per_second)

func _process(delta: float) -> void:
	if visible: 
		# Use delta time to get approx frames per second and round to two decimals places !Disable VSync if fps is stuck at 60!
		frames_per_second = "%.2f" % (1.0/delta)
		#frames_per_second = Engine.get_frames_per_second()
		#property.text = property.name + ": " + frames_per_second

	# Gobal debug properties
	Global.debug.add_property("FPS", frames_per_second, 1)

func _input(event: InputEvent) -> void:
	# Toggle debug panel
	if event.is_action_pressed("debug"):
		visible = !visible

# Dubug funtion to add and update property
func add_property(title: String, value, order):
	var target
	target = property_container.find_child(title, true, false) # Try to find Lable node with the same name
	if !target: # If there is no current Label node for the property (ie. inital load)
		target = Label.new() # Create new Label node
		property_container.add_child(target) # Add new node as child to the VBox container
		target.name = title # Set name to title
		target.text = target.name + ": " + str(value) # Set text value
	elif visible:
		target.text = title + ": " + str(value) # Update text value
		property_container.move_child(target, order) # Reorder property based on given order value

# Callable function to add new debug property
#func add_debug_property(title: String, value):
	#property = Label.new() # Create new Label node
	#property_container.add_child(property) # Add new node as child to the VBox container
	#property.name = title
	#property.text = property.name + value
