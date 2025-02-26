@tool
class_name PTwindowReminder extends Window

#region @onready vars
@onready var parent := $".."
@onready var bg_color_rect:ColorRect = $Control/ColorRect
@onready var time_label:Label = $Control/MarginContainer/VBoxContainer/TimeLabel
@onready var snooze_slider:HSlider = $Control/MarginContainer/VBoxContainer/HBoxContainer/SnoozeHSlider
@onready var snooze_label:Label = $Control/MarginContainer/VBoxContainer/HBoxContainer/SnoozeLabel
@onready var quit_button:TextureButton = $Control/MarginContainerCollapse/QuitButton
@onready var quit_button_bg_color_rect:ColorRect = $Control/MarginContainerCollapse/ColorRect

@onready var page_flip_audio:AudioStreamPlayer
@onready var scribble_audio:AudioStreamPlayer
@onready var pencil_tick_audio:AudioStreamPlayer
#endregion

const BASE_DB_PAGE_FLIP  :int =   0
const BASE_DB_SCRIBBLE   :int = -15
const BASE_DB_PENCIL_TICK:int = -23

const POSITION_OFFSET:int = 410
const SNOOZE_TEXT:String = "%.0f sec"

var is_ready:bool = false
var stats:StatsDataPT = StatsDataPT.new()

func _notification(what:int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST: _collapse_window()
		_: pass

func _ready() -> void:
	if is_ready:
		# Get AudioPlayer references
		page_flip_audio   = $"../Audio/AudioStreamPlayer1"
		if stats.audio_enabled:
			page_flip_audio.volume_db = BASE_DB_PAGE_FLIP + stats.audio_addend
			page_flip_audio.play()

		scribble_audio    = $"../Audio/AudioStreamPlayer2"
		pencil_tick_audio = $"../Audio/AudioStreamPlayer3"

		# Connnect signals
		parent.pt_free_reminder.connect(_collapse_window)
		parent.pt_remaining_time.connect(func(remaining_time:String) -> void:
			time_label.text = remaining_time.erase(1,3)
		)

		_expand_window(); _load_settings(); _set_colors()


func _load_settings() -> void:
	snooze_slider.value = stats.snooze_time; _set_snooze_time_label(stats.snooze_time)


func _set_colors() -> void:
	var editor_settings:EditorSettings = EditorInterface.get_editor_settings()
	var interface_base_color  :Color = editor_settings.get_setting("interface/theme/base_color")
	var interface_accent_color:Color = editor_settings.get_setting("interface/theme/accent_color")

	quit_button_bg_color_rect.color = interface_base_color
	quit_button.self_modulate = interface_accent_color.darkened(0.25)

	interface_accent_color.a = 0.05
	bg_color_rect.color = interface_base_color.blend(interface_accent_color)

	if bg_color_rect.color.get_luminance() <= 0.5: bg_color_rect.color = interface_base_color.lightened(0.125)
	else: bg_color_rect.color = interface_base_color.darkened(0.125)
	bg_color_rect.color = bg_color_rect.color.clamp(Color(0.2,0.2,0.2),Color(0.8,0.8,0.8))


func _expand_window() -> void:
	self.set_current_screen(DisplayServer.window_get_current_screen())
	position.x = DisplayServer.screen_get_position(self.get_current_screen()).x - POSITION_OFFSET
	var tween:Tween = create_tween()
	tween.tween_property(self,"position",Vector2i(position.x + (POSITION_OFFSET + 20),position.y),1.1)


func _collapse_window() -> void:
	var tween:Tween = create_tween()
	if stats.audio_enabled:
		page_flip_audio.volume_db = BASE_DB_PAGE_FLIP + stats.audio_addend
		page_flip_audio.play()
	tween.tween_property(self,"position",Vector2i(position.x - POSITION_OFFSET,position.y),1.1)
	if stats.audio_enabled: await page_flip_audio.finished
	else: await tween.finished
	queue_free()


func _set_snooze_time_label(snooze_time:int) -> void:
	snooze_label.text = SNOOZE_TEXT % [snooze_time]
	if snooze_time >= 10 and snooze_time < 100: snooze_label.text = str(0) + snooze_label.text


func _on_dismiss_button_pressed() -> void:
	parent.dismissed = true
	_collapse_window()


func _on_snooze_button_pressed() -> void:
	parent.snooze = true
	_collapse_window()


func _on_quit_button_pressed() -> void: _collapse_window()


func _on_h_slider_drag_started() -> void:
	if stats.audio_enabled:
		scribble_audio.volume_db = BASE_DB_SCRIBBLE + stats.audio_addend
		scribble_audio.play()


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	scribble_audio.stop()
	if stats.audio_enabled:
		pencil_tick_audio.volume_db = BASE_DB_PENCIL_TICK + stats.audio_addend
		pencil_tick_audio.play()


func _on_h_slider_value_changed(value: float) -> void:
	stats.snooze_time = snooze_slider.value
	_set_snooze_time_label(value)
