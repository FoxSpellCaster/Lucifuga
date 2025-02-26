@tool
class_name PTwindowSettings extends Window

#region @onready vars
# Grid 1 refs
@onready var session_label:Label                       = $ScrollContainer/Control/MarginContainer/VBoxContainer/GeneralGrid/SessionLabel
@onready var session_time_slider:HSlider               = $ScrollContainer/Control/MarginContainer/VBoxContainer/GeneralGrid/SessionHSlider
@onready var break_window_size_label:Label             = $ScrollContainer/Control/MarginContainer/VBoxContainer/GeneralGrid/SizeLabel
@onready var break_window_size_slider:HSlider          = $ScrollContainer/Control/MarginContainer/VBoxContainer/GeneralGrid/SizeHSlider
@onready var break_window_exclusive_button:CheckButton = $ScrollContainer/Control/MarginContainer/VBoxContainer/GeneralGrid/ExclusiveButton
@onready var break_window_message_button:CheckButton   = $ScrollContainer/Control/MarginContainer/VBoxContainer/GeneralGrid/MessageButton

# Grid 2 refs
@onready var break_window_countdown_button:CheckButton         = $ScrollContainer/Control/MarginContainer/VBoxContainer/TimerGrid/CountdownButton
@onready var break_window_countdown_label:Label                = $ScrollContainer/Control/MarginContainer/VBoxContainer/TimerGrid/CountdownLabel
@onready var break_window_countdown_slider:HSlider             = $ScrollContainer/Control/MarginContainer/VBoxContainer/TimerGrid/CountdownHSlider
@onready var break_window_countdown_timeout_button:CheckButton = $ScrollContainer/Control/MarginContainer/VBoxContainer/TimerGrid/CountdownTimeoutButton
@onready var break_window_countdown_timeout_label:Label        = $ScrollContainer/Control/MarginContainer/VBoxContainer/TimerGrid/CountdownTimeoutLabel
@onready var break_window_countdown_timeout_slider:HSlider     = $ScrollContainer/Control/MarginContainer/VBoxContainer/TimerGrid/CountdownTimeoutHSlider

# Grid 3 refs
@onready var break_window_image_filter_colorpicker:ColorPickerButton = $ScrollContainer/Control/MarginContainer/VBoxContainer/ImageGrid/ImageColorPickerButton
@onready var break_window_ui_filter_colorpicker:ColorPickerButton    = $ScrollContainer/Control/MarginContainer/VBoxContainer/ImageGrid/UiColorPickerButton

# Grid 4 refs
@onready var reminder_window_enabled_button:CheckButton = $ScrollContainer/Control/MarginContainer/VBoxContainer/ReminderGrid/ReminderButton
@onready var reminder_window_popup_time_label:Label     = $ScrollContainer/Control/MarginContainer/VBoxContainer/ReminderGrid/ReminderLabel
@onready var reminder_window_popup_time_slider:HSlider  = $ScrollContainer/Control/MarginContainer/VBoxContainer/ReminderGrid/ReminderHSlider

# Grid 5 refs
@onready var audio_button:CheckButton = $ScrollContainer/Control/MarginContainer/VBoxContainer/AudioGrid/AudioButton
@onready var audio_slider:HSlider     = $ScrollContainer/Control/MarginContainer/VBoxContainer/AudioGrid/AudioHSlider
@onready var audio_label:Label        = $ScrollContainer/Control/MarginContainer/VBoxContainer/AudioGrid/Label

# Others
@onready var bg_color_rect:ColorRect = $ColorRect
@onready var reset_button:Button     = $ScrollContainer/Control/MarginContainer/VBoxContainer/ResetButton
#endregion

#region constants
const AUDIO_ADDEND_TEXT:String      = " Audio Addend: %.0f db"
const AUTOCLOSE_TEXT:String         = " Autoclose '%.0f' sec after Timeout"
const BREAK_WINDOW_SIZE_TEXT:String = " Break Window Size: %d percent"
const COUNTDOWN_TIME_TEXT:String    = " Countdown Time: %.0f min"
const REMINDER_TIME_TEXT:String     = " Reminder at '%.0f' sec left"
const SESSION_TIME_TEXT:String      = " Session Time: %.0f min"
#endregion

var stats:StatsDataPT = StatsDataPT.new()

func _notification(what:int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST: queue_free()
		_: pass

func _ready() -> void: _load_settings(); _connect_settings()

func _load_settings() -> void:
	bg_color_rect.color = (EditorInterface.get_editor_settings()).get_setting("interface/theme/base_color")

	# Grid 1 settings
	session_time_slider.value = stats.session_time / 60
	session_label.text = SESSION_TIME_TEXT % [session_time_slider.value]
	break_window_size_slider.value = stats.break_window_size
	break_window_size_label.text = BREAK_WINDOW_SIZE_TEXT % [break_window_size_slider.value]
	break_window_exclusive_button.set_pressed_no_signal(!stats.break_window_exclusive)
	break_window_message_button.set_pressed_no_signal(!stats.break_window_message)

	# Grid 2 settings
	break_window_countdown_button.set_pressed_no_signal(stats.break_window_timer_countdown)
	break_window_countdown_timeout_button.set_pressed_no_signal(stats.break_window_close_on_timeout)
	if not break_window_countdown_button.button_pressed:
		break_window_countdown_timeout_button.disabled = true
	break_window_countdown_slider.value = stats.break_window_time / 60
	break_window_countdown_slider.editable = stats.break_window_timer_countdown
	break_window_countdown_label.text = COUNTDOWN_TIME_TEXT % [break_window_countdown_slider.value]
	break_window_countdown_timeout_slider.value = stats.break_window_timeout_time
	break_window_countdown_timeout_slider.editable = stats.break_window_close_on_timeout
	break_window_countdown_timeout_label.text = AUTOCLOSE_TEXT % [break_window_countdown_timeout_slider.value]

	# Grid 2 settings
	break_window_image_filter_colorpicker.color = stats.break_window_image_filter_color
	break_window_ui_filter_colorpicker.color = stats.break_window_ui_bg_color

	# Grid 3 settings
	reminder_window_enabled_button.set_pressed_no_signal(stats.reminder_window_enabled)
	reminder_window_popup_time_slider.value = stats.reminder_time
	reminder_window_popup_time_label.text = REMINDER_TIME_TEXT % [stats.reminder_time]

	# Grid 4 settings
	audio_button.set_pressed_no_signal(stats.audio_enabled)
	audio_slider.value = stats.audio_addend
	audio_label.text = AUDIO_ADDEND_TEXT % [audio_slider.value]


func _connect_settings() -> void:
	# Grid 1 connections
	session_time_slider.value_changed.connect(func(value:float) -> void:
		session_label.text = SESSION_TIME_TEXT % [value]
		stats.session_time = value * 60
	)
	break_window_size_slider.value_changed.connect(func(value:float) -> void:
		break_window_size_label.text = BREAK_WINDOW_SIZE_TEXT % [value]
		stats.break_window_size = value
	)
	break_window_exclusive_button.toggled.connect(func(toggled_on:bool) -> void:
		stats.break_window_exclusive = !toggled_on
	)
	break_window_message_button.toggled.connect(func(toggled_on:bool) -> void:
		stats.break_window_message = !toggled_on
	)

	# Grid 2 connections
	break_window_countdown_button.toggled.connect(func(toggled_on:bool) -> void:
		stats.break_window_timer_countdown = toggled_on
		break_window_countdown_slider.editable = toggled_on
		break_window_countdown_timeout_button.button_pressed = toggled_on
		break_window_countdown_timeout_button.disabled = !toggled_on
		break_window_countdown_timeout_slider.editable = toggled_on
	)
	break_window_countdown_timeout_button.toggled.connect(func(toggled_on:bool) -> void:
		stats.break_window_close_on_timeout = toggled_on
		break_window_countdown_timeout_slider.editable = toggled_on
	)
	break_window_countdown_slider.value_changed.connect(func(value:float) -> void:
		break_window_countdown_label.text = COUNTDOWN_TIME_TEXT % [value]
		stats.break_window_time = value * 60
	)
	break_window_countdown_timeout_slider.value_changed.connect(func(value:float) -> void:
		break_window_countdown_timeout_label.text = AUTOCLOSE_TEXT % [value]
		stats.break_window_timeout_time = int(value)
	)

	# Grid 3 connections
	break_window_image_filter_colorpicker.color_changed.connect(func(color:Color) -> void:
		stats.break_window_image_filter_color = color
	)
	break_window_ui_filter_colorpicker.color_changed.connect(func(color:Color) -> void:
		stats.break_window_ui_bg_color = color
	)

	# Grid 4 connections
	reminder_window_enabled_button.toggled.connect(func(toggled_on:bool) -> void:
		stats.reminder_window_enabled = toggled_on
	)
	reminder_window_popup_time_slider.value_changed.connect(func(value:float) -> void:
		reminder_window_popup_time_label.text = REMINDER_TIME_TEXT % [value]
		stats.reminder_time = int(value)
	)

	# Grid 5 connections
	audio_button.toggled.connect(func(toggled_on:bool) -> void:
		stats.audio_enabled = toggled_on
	)
	audio_slider.value_changed.connect(func(value:float) -> void:
		audio_label.text = AUDIO_ADDEND_TEXT % [value]
		stats.audio_addend = int(value)
	)


func _on_reset_button_pressed() -> void:
	stats = StatsDataPT.new()
	_load_settings()
