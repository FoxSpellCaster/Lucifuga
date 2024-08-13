extends Node

@export var animation_tree : AnimationTree
@export var player : Player

var on_floor_blend : float = 1
var on_floor_blend_target : float = 1

var tween : Tween

var current_stance_name = "upright"

func _physics_process(delta):
	on_floor_blend_target = 1 if player.is_on_floor() else 0
	on_floor_blend = lerp(on_floor_blend, on_floor_blend_target, 10 * delta)
	animation_tree["parameters/on_floor_blend/blend_amount"] = on_floor_blend


func _jump(jump_state : JumpState):
	animation_tree["parameters/" + jump_state.animation_name + "/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE


func _on_set_movement_state(_movement_state : MovementState):
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(animation_tree, "parameters/" + current_stance_name + "_movement_blend/blend_position", _movement_state.id, 0.25)
	tween.parallel().tween_property(animation_tree, "parameters/movement_anim_speed/scale", _movement_state.animation_speed, 0.7)


func _on_set_stance(_stance : Stance):
	animation_tree["parameters/stance_transition/transition_request"] = _stance.name
	current_stance_name = _stance.name

