class_name StatsDataPT extends Resource

# Dock / Global Settings
@export var session_time_counter:int = 45 * 60 # In seconds
@export var session_time:int = 45 * 60 # In seconds


# Break Window Settings
@export var break_window_exclusive:bool = false
@export var break_window_size:float = 110 # In percentage (100 == minimum / 200 = maximum)
@export var break_window_message:bool = true

@export var break_window_timer_countdown:bool = true
@export var break_window_time:int = 8 * 60 # In seconds
@export var break_window_close_on_timeout:bool = true
@export var break_window_timeout_time:int = 15 # In seconds

@export var break_window_image_filter_color:Color = Color.html("38134a")
@export var break_window_ui_bg_color:Color = Color.html("450e2869")


# Reminder Window Settings
@export var reminder_window_enabled:bool = true
@export var reminder_time:int = 0.5 * 60 # In seconds
@export var snooze_time:int = 120 # In seconds


# Audio Settings
@export var audio_enabled:bool = true
@export var audio_addend:int = 0
