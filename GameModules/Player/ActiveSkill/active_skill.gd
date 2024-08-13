@icon("active_skill_icon.png")
extends Node3D
class_name ActiveSkill

enum State {READY, WINDING_UP, DELIVERING, RECOVERING}

@export_category("Animation")
@export var animation_name : StringName
@export var windup_duration :  float
@export var delivery_duration :  float
@export var recovery_duration :  float

@export_category("Movement")
@export var acceleration : float = 8
@export var dash_delay : float = 0.1
@export var dash_duration : float = 0.2
@export var dash_velocity : Vector3 = Vector3(0, 0, 5)

@export_category("Camera")
@export var camera_fov : float = 70

@export_category("VFX")
@export var vfx_delay : float = 0.1
@export var vfx_duration : float = 0.3
@export var vfx : GPUTrail3D


func _ready():
	load_vfx()


func load_vfx():
	vfx.show()
	await get_tree().process_frame
	await get_tree().process_frame
	vfx.hide()
