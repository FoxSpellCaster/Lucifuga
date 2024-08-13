extends CharacterBody3D
class_name Player

signal pressed_primary_fire
signal pressed_jump(jump_state : JumpState)
signal changed_stance(stance : Stance)
signal changed_movement_state(_movement_state: MovementState)
signal changed_movement_direction(_movement_direction: Vector3)

@export var max_air_jump : int = 1
@export var jump_states : Dictionary
@export var stances : Dictionary

var air_jump_counter : int = 0
var movement_direction : Vector3
var current_stance_name : String = "upright"
var current_movement_state : MovementState
var current_movement_state_name : String
var stance_antispam_timer : SceneTreeTimer

var is_attacking : bool = false


func _ready():
	stance_antispam_timer = get_tree().create_timer(0.25)
	
	changed_movement_direction.emit(Vector3.BACK)
	set_stance(current_stance_name)
	set_movement_state("stand")


func _input(event):
	if event.is_action_pressed("primary_fire"):
		pressed_primary_fire.emit()
		set_stance("upright")
	
	if event.is_action_pressed("movement") or event.is_action_released("movement"):
		movement_direction.x = Input.get_action_strength("left") - Input.get_action_strength("right")
		movement_direction.z = Input.get_action_strength("forward") - Input.get_action_strength("back")
		
		if is_movement_ongoing():
			if Input.is_action_pressed("sprint"):
				set_movement_state("sprint")
				if current_stance_name == "stealth":
					set_stance("upright")
			else:
				if Input.is_action_pressed("walk"):
					set_movement_state("walk")
				else:
					set_movement_state("run")
		else:
			set_movement_state("stand")
	
	if event.is_action_pressed("jump") and not is_attacking:
		if air_jump_counter <= max_air_jump:
			if is_stance_blocked("upright"):
				return
			
			if current_stance_name != "upright" and current_stance_name != "stealth":
				set_stance("upright")
				return
			
			var jump_name = "ground_jump"
			
			if air_jump_counter > 0:
				jump_name = "air_jump"
			
			pressed_jump.emit(jump_states[jump_name])
			air_jump_counter += 1
	
	if is_on_floor():
		for stance in stances.keys():
			if event.is_action_pressed(stance):
				set_stance(stance)


func _physics_process(delta):
	if is_movement_ongoing():
		changed_movement_direction.emit(movement_direction)
		
	if is_on_floor():
		air_jump_counter = 0
	elif air_jump_counter == 0:
		air_jump_counter = 1


func is_movement_ongoing() -> bool:
	return abs(movement_direction.x) > 0 or abs(movement_direction.z) > 0


func set_movement_state(state : String):
	var stance = get_node(stances[current_stance_name])
	current_movement_state = stance.get_movement_state(state)
	current_movement_state_name = state
	changed_movement_state.emit(current_movement_state)


func set_stance(_stance_name : String):
	if stance_antispam_timer.time_left > 0:
		return
	stance_antispam_timer = get_tree().create_timer(0.25)
	
	var next_stance_name : String
	
	if _stance_name == current_stance_name:
		next_stance_name = "upright"
	else:
		next_stance_name = _stance_name
	
	if is_stance_blocked(next_stance_name):
		return
	
	var current_stance = get_node(stances[current_stance_name])
	current_stance.collider.disabled = true
	
	current_stance_name = next_stance_name
	current_stance = get_node(stances[current_stance_name])
	current_stance.collider.disabled = false
	
	changed_stance.emit(current_stance)
	set_movement_state(current_movement_state_name)


func is_stance_blocked(_stance_name : String) -> bool:
	var stance = get_node(stances[_stance_name])
	return stance.is_blocked()
