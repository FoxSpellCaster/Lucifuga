@tool
extends TextureButton

var color:Color
@export_color_no_alpha var color_toggled:Color = Color.RED
@export_color_no_alpha var color_disabled:Color = Color.DIM_GRAY

func _ready() -> void:
	color = EditorInterface.get_editor_settings().get_setting("interface/theme/accent_color")
	self_modulate = color

	self.toggled.connect(func(toggled:bool) -> void:
		if toggled: self_modulate = color_toggled
		else: self_modulate = color
	)


func set_disabled_custom(disabled:bool) -> void:
	self.disabled = disabled
	if disabled: self_modulate = color_disabled
	else: self_modulate = color
