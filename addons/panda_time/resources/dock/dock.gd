@tool
class_name PandaTimeDock extends Control

#region @onready vars
@onready var timer:Timer = $SessionTimer
@onready var timer_label:Label = $MarginContainer/VBoxContainer/TimerLabel
@onready var skip_button:TextureButton = $MarginContainer/VBoxContainer/SkipButton
@onready var stop_button:TextureButton = $MarginContainer/VBoxContainer/StopButton
@onready var settings_button:TextureButton = $MarginContainer/VBoxContainer/SettingsButton
#endregion

# Signals
signal pt_remaining_time(remaining_time:String)
signal pt_free_reminder

# Paths and Stats
const PT_WINDOW_BREAK:Resource = preload("res://addons/panda_time/resources/windows/break/window_break.tscn")
const PT_WINDOW_REMINDER:Resource = preload("res://addons/panda_time/resources/windows/reminder/window_reminder.tscn")
const PT_WINDOW_SETTINGS:Resource = preload("res://addons/panda_time/resources/windows/settings/window_settings.tscn")
const ICON_PATH:String = "res://addons/panda_time/resources/images/icon.ico"
const ROOT_PATH:String = "user://"
const FILE_NAME:String = "panda_time.tres"
var stats:StatsDataPT

# Timer, Reminder, Settings, Others
const TIMER_TEXT:String = "%s:%s:%s"
var snooze:bool = false
var dismissed:bool = false
var is_settings_window_open:bool = false
var plugin_is_running:bool = false


func _ready() -> void:
	if plugin_is_running:
		# Verify previous saved data
		if _verify_file() == false:
			stats = StatsDataPT.new()
			write_savefile()
		else: stats = _load_savefile()

		_on_break_timer_timeout()
		_start_timer()

		skip_button.pressed.connect(_open_new_session_window)
		stop_button.toggled.connect(func(toggled:bool) -> void: timer.paused = toggled)
		settings_button.pressed.connect(_open_new_settings_window)


func _on_break_timer_timeout() -> void:
	var hours:String = str(stats.session_time_counter / 3600)
	var minutes:String = str(stats.session_time_counter % 3600 / 60)
	var seconds:String = str(stats.session_time_counter % 3600 % 60)
	timer_label.text = format_time(TIMER_TEXT,hours,minutes,seconds)

	if stats.session_time_counter == stats.reminder_time and stats.reminder_window_enabled:
		_open_new_reminder_window()

	if stats.session_time_counter == 0 and (dismissed or snooze):
		if dismissed: _reminder_set_session_time(stats.session_time)
		if snooze: _reminder_set_session_time(stats.snooze_time)
	elif stats.session_time_counter == 0:
		_open_new_session_window()

	pt_remaining_time.emit(timer_label.text)
	stats.session_time_counter -= 1


func _reminder_set_session_time(time:int) -> void:
	dismissed = false
	snooze = false
	stats.session_time_counter = time


func format_time(FORMAT:String,hours:String,minutes:String,seconds:String) -> String:
	if int(hours) < 10: hours = str(0)+hours
	if int(minutes) < 10: minutes = str(0)+minutes
	if int(seconds) < 10: seconds = str(0)+seconds
	return FORMAT % [hours,minutes,seconds]


func _open_new_session_window() -> void:
	timer.stop()
	pt_free_reminder.emit()

	skip_button.set_disabled_custom(true)
	stop_button.set_disabled_custom(true)
	settings_button.set_disabled_custom(true)

	var window:PTwindowBreak = PT_WINDOW_BREAK.instantiate()

	window.stats = stats
	window.is_ready  = true
	window.exclusive = true if not stats.break_window_exclusive else false
	window.size = Vector2.ONE * (window.size * (stats.break_window_size * 0.01))
	window.position = DisplayServer.screen_get_size() / 2 - window.size / 2
	window.new_session_time = stats.session_time
	DisplayServer.set_native_icon(ICON_PATH)

	add_child(window,false,Node.INTERNAL_MODE_FRONT)
	window.set_current_screen(DisplayServer.window_get_current_screen())

	window.tree_exiting.connect(func() -> void:
		dismissed = false
		snooze = false

		stats.session_time_counter = window.new_session_time
		stats.session_time = window.new_session_time
		_on_break_timer_timeout()
		_start_timer()

		skip_button.set_disabled_custom(false)
		stop_button.set_disabled_custom(false)
		if !is_settings_window_open: settings_button.set_disabled_custom(false)
	)


func _open_new_reminder_window() -> void:
	var window:PTwindowReminder = PT_WINDOW_REMINDER.instantiate()
	window.is_ready = true
	window.stats = stats
	window.position.y = DisplayServer.screen_get_usable_rect().size.y - window.size.y - 20
	DisplayServer.set_native_icon(ICON_PATH)
	add_child(window)

	window.tree_exiting.connect(func() -> void:
		stats = window.stats
	)


func _open_new_settings_window() -> void:
	settings_button.set_disabled_custom(true)
	is_settings_window_open = true

	var window:PTwindowSettings = PT_WINDOW_SETTINGS.instantiate()

	window.stats = stats
	window.position = DisplayServer.screen_get_size() / 2 - window.size / 2
	DisplayServer.set_native_icon(ICON_PATH)

	add_child(window,false,Node.INTERNAL_MODE_FRONT)
	window.set_current_screen(DisplayServer.window_get_current_screen())

	window.tree_exiting.connect(func() -> void:
		stats = window.stats
		settings_button.set_disabled_custom(false)
		is_settings_window_open = false
	)


func _start_timer() -> void:
	timer.paused = false
	timer.start(1)


# Data related functions
func _verify_file() -> bool:
	if DirAccess.open(ROOT_PATH).file_exists(FILE_NAME) == true: return true
	else: return false

func _load_savefile() -> Resource: return ResourceLoader.load(ROOT_PATH+FILE_NAME,"",0)

func write_savefile() -> void:
	ResourceSaver.save(stats,ROOT_PATH+FILE_NAME,0)
