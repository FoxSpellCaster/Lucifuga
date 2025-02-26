@tool
class_name PTwindowBreak extends Window

# Constants
const IMAGE_ROOT_PATH:String = "res://addons/panda_time/images/"
const IMAGE_EXTENSIONS:Array[String] = ["png","jpg","jpeg","svg"]
const SEPARATOR:String = "/"
const ERR:String = "--> PT: An error occurred when trying to access the path!"
const TIMER_TEXT:String = "%s : %s : %s"
const SESSION_TEXT:String = "%s min"

const DB_TIMEOUT_DEFAULT_STEP:int = 3
const MAX_DB_TIMEOUT:int =   8 # Must be positive
const MIN_DB_TIMEOUT:int = -30 # Must be negative

const BASE_DB_PAGE_FLIP  :int =   3
const BASE_DB_SCRIBBLE   :int = -10
const BASE_DB_PENCIL_TICK:int = -18

const FADE_SPEED_IN :int =  3
const FADE_SPEED_OUT:int = 11

const THEME_OUTLINE_SIZE:int = 9
const THEME_SHADOW_COLOR:Color = Color(0.14,0.14,0.14,0.9)
const SELF_MODULATE:Color = Color.CRIMSON

#region @onready vars
@onready var parent := $".."
@onready var bg_color_rect:ColorRect = $Control/BgColorRect
@onready var bg_texture_rect:TextureRect = $Control/BgTextureRect
@onready var message_container:MarginContainer = $Control/MsgMarginContainer
@onready var message_bg_rect:ColorRect = $Control/MsgMarginContainer/MsgColorRect
@onready var message_label:Label = $Control/MsgMarginContainer/MsgLabel
@onready var timer:Timer = $Timer
@onready var timer_label:Label = $Control/TimerMarginContainer/TimerLabel
@onready var settings_bg_rect:ColorRect = $Control/SettingsMarginContainer/SettingsColorRect
@onready var next_button:Button  = $Control/SettingsMarginContainer/Margin/VBox/NextButton
@onready var session_label:Label = $Control/SettingsMarginContainer/Margin/VBox/HBox/SessionLabel
@onready var session_slider:HSlider = $Control/SettingsMarginContainer/Margin/VBox/HBox/SessionHSlider
@onready var anim_player:AnimationPlayer = $AnimationPlayer

@onready var timeout_audio:AudioStreamPlayer = $TimeoutAudioPlayer
@onready var page_flip_audio:AudioStreamPlayer
@onready var scribble_audio:AudioStreamPlayer
@onready var pencil_tick_audio:AudioStreamPlayer
#endregion

# Variables
var is_ready:bool = false
var file_array = []
var is_timer_countdown:bool = false
var countdown_time:int = 5 * 60 # In seconds
var new_session_time:int

var message:Dictionary = {
	1:   "Stretch those legs!",
	2:   "Eyes need rest too.",
	3:   "Time for a breather!",
	4:   "Refresh your mind.",
	5:   "Break time, buddy!",
	6:   "Take a walk outside.",
	7:   "A break awaits you.",
	8:   "Pause and relax.",
	9:   "Stretch and unwind.",
	10:  "Blink away fatigue.",
	11:  "Relaxation incoming!",
	12:  "Let's stretch it out!",
	13:  "Move those muscles!",
	14:  "A moment of zen.",
	15:  "Eyes off the screen.",
	16:  "Chill for a bit.",
	17:  "Take a breather.",
	18:  "Time to recharge.",
	19:  "Ready for a break?",
	20:  "Refresh and revive.",
	21:  "Clear your mind.",
	22:  "Breathe deeply now.",
	23:  "Brain break time!",
	24:  "Unwind and relax.",
	25:  "Relaxation station.",
	26:  "Step away for a sec.",
	27:  "Time to chillax.",
	28:  "Switch off, recharge.",
	29:  "Refresh your focus.",
	30:  "Let's take five.",
	31:  "Detox from screens.",
	32:  "A break is brewing.",
	33:  "Relax and rejuvenate.",
	34:  "Revitalize yourself.",
	35:  "Get up and move.",
	36:  "Ease your mind.",
	37:  "Break, don't break!",
	38:  "Revive your energy.",
	39:  "Step back and relax.",
	40:  "Relax, it's break time.",
	41:  "Time to decompress.",
	42:  "Take a little breather.",
	43:  "Just breathe, relax.",
	44:  "Break time, cheers!",
	45:  "Unplug for a while.",
	46:  "Relax and recharge.",
	47:  "Take a mini vacation.",
	48:  "Disconnect, rejuvenate.",
	49:  "Break time bliss!",
	50:  "Recharge your batteries!",
	51:  "Refresh your focus, friend.",
	52:  "Give your mind a break.",
	53:  "Eyes off, relax on.",
	54:  "A short break, big impact.",
	55:  "Take a breather, champ.",
	56:  "Step away, clear mind.",
	57:  "Reset and re-energize.",
	58:  "Relax, you've earned it.",
	59:  "Pause, then play better.",
	60:  "Unwind, then conquer.",
	61:  "Detox from the screen.",
	62:  "Rejuvenate your spirit.",
	63:  "Mindfulness moment now.",
	64:  "Reboot your brain.",
	65:  "Break time, find peace.",
	66:  "A moment to recharge.",
	67:  "Step back, find balance.",
	68:  "Refresh, refocus, restart.",
	69:  "Revive your creativity.",
	70:  "Take a timeout, superstar.",
	71:  "Decompress and de-stress.",
	72:  "Unplug, unwind, relax.",
	73:  "A brief escape awaits.",
	74:  "Break the routine, relax.",
	75:  "Renew your energy, now.",
	76:  "Refreshment break, ah!",
	77:  "Quick break, big results.",
	78:  "Time out for tranquility.",
	79:  "Chill out, cool down.",
	80:  "Take five, rejuvenate.",
	81:  "Relax, then rock on.",
	82:  "Reconnect with yourself.",
	83:  "Hit pause, find peace.",
	84:  "Revitalize your spirit.",
	85:  "Refresh, then return.",
	86:  "Unwind, then work wonders.",
	87:  "Breathe, reset, resume.",
	88:  "Pause for self-care.",
	89:  "Recharge, refuel, relax.",
	90:  "Refreshment break, hooray!",
	91:  "Short break, big benefits.",
	92:  "A break, the best medicine.",
	93:  "Time to chill, recharge.",
	94:  "Revitalize, then conquer.",
	95:  "A quick break, huge help.",
	96:  "Find calm, then conquer.",
	97:  "Short break, sharp mind.",
	98:  "Pause for positivity.",
	99:  "Refresh, then rock it!",
	100: "A break, a better you.",

	101: "Take a code break.",
	102: "Debug later, relax now.",
	103: "Chill, no syntax stress.",
	104: "Time for coding siesta.",
	105: "Decompress your code.",
	106: "Ctrl+Alt+Chill mode.",
	107: "Pause for byte-size fun.",
	108: "Relax, code will wait.",
	109: "Chillax and debug.",
	110: "Debug tomorrow, Chill now.",
	111: "Relax, no semicolon panic.",
	112: "Coffee break, code waits.",
	113: "Chill vibes, no bugs.",
	114: "Relax, no stack overflow.",
	115: "Unwind, refactor later.",
	116: "Take a chill pill.",
	117: "Code off, chill on.",
	118: "A delightful timeout.",
	119: "Error-free zone, relax.",
	120: "Chill like a compiler.",
	121: "Timeout for code cooldown.",
	122: "Debug delay, chill play.",
	123: "Chillwave coding playlist.",
	124: "Breakpoint for relaxation.",
	125: "Pause for coding laughter.",
	126: "Chill code, hot cocoa.",
	127: "No stress, just JSON.",
	128: "Relax, no merge conflicts.",
	129: "Code freeze, chill breeze.",
	130: "Escape the curly braces.",
	131: "Chill, no race conditions.",
	132: "Breathe, code gently.",
	133: "No more compiler tantrums.",
	134: "Take a code nap.",
	135: "Ctrl+Zzz relaxation.",
	136: "Chillax, no runtime errors.",
	137: "Relax, no memory leaks.",
	138: "Syntax serenity now.",
	139: "Decompress with code memes.",
	140: "Chill like a coding ninja.",
	141: "Code unwind session.",
	142: "Debug postponed!",
	143: "Code later, laugh now.",
	144: "Chill, no infinite loops.",
	145: "Time to code your dreams.",
	146: "Freetime, no bugs invited!",
	147: "Code zen zone activated.",
	148: "Take a chill byte.",
	149: "Relax, happiness loading.",

	150: "Time to RTFMM.",
}
var timeout_message:Dictionary = {
	1:  "Break is done",
	2:  "Break is over",
	3:  "Break is up",
	4:  "No more break",

	5:  "Time is done",
	6:  "Time is over",
	7:  "Time is up",
	8:  "Time to code",

	9:  "Enough rest",
	10: "Work calls",
	11: "Back to coding",
	12: "Resume coding",
	13: "Fun is over",
	14: "Back at it",
}

var hours  :String = "0"
var minutes:String = "0"
var seconds:String = "0"

var stats:StatsDataPT = StatsDataPT.new()


func _notification(what:int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST: queue_free()
		_: pass


func _ready() -> void:
	if is_ready:
		# Get AudioPlayer references
		page_flip_audio   = $"../Audio/AudioStreamPlayer1"
		scribble_audio    = $"../Audio/AudioStreamPlayer2"
		pencil_tick_audio = $"../Audio/AudioStreamPlayer3"

		# Startup
		if stats.audio_enabled:
			page_flip_audio.volume_db = BASE_DB_PAGE_FLIP + stats.audio_addend
			page_flip_audio.play()
		anim_player.speed_scale = FADE_SPEED_IN
		anim_player.play("fade_in")

		# Set random background and text
		_get_dir_contents(IMAGE_ROOT_PATH)
		if file_array.size() > 0: bg_texture_rect.texture = load(file_array[randi_range(0,file_array.size()-1)])
		if stats.break_window_message == true:
			message_bg_rect.color = stats.break_window_ui_bg_color
			message_label.text = message[randi_range(1,message.size())]
		else:
			message_container.visible = false

		# Load settings and data
		bg_color_rect.color = stats.break_window_image_filter_color
		settings_bg_rect.color = stats.break_window_ui_bg_color
		is_timer_countdown = stats.break_window_timer_countdown
		countdown_time = stats.break_window_time

		# Set timer label
		timer_label.text = TIMER_TEXT % ["00","00","00"]
		timer_label.add_theme_constant_override("outline_size", 0)
		timer_label.add_theme_color_override("font_shadow_color", THEME_SHADOW_COLOR)

		# Session
		_set_session_time_label()
		session_slider.value = new_session_time / 60

		# Connect Signals
		next_button.pressed.connect(_close_window)
		session_slider.drag_started.connect(func() -> void:
			if stats.audio_enabled:
				scribble_audio.volume_db = BASE_DB_SCRIBBLE + stats.audio_addend
				scribble_audio.play()
		)
		session_slider.drag_ended.connect(func(_bool:bool) -> void:
			scribble_audio.stop()
			if stats.audio_enabled:
				pencil_tick_audio.volume_db = BASE_DB_PENCIL_TICK + stats.audio_addend
				pencil_tick_audio.play()
		)
		session_slider.value_changed.connect(func(value:float) -> void:
			new_session_time = value * 60
			_set_session_time_label()
		)

		# Start the break time
		timer.start(1)
		if stats.audio_enabled:
			timeout_audio.volume_db = MIN_DB_TIMEOUT + stats.audio_addend


func _get_dir_contents(path:String):
	var dir := DirAccess.open(path)
	if not dir: push_error(ERR)
	else:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if dir.current_is_dir(): _get_dir_contents(path+SEPARATOR+file_name)
			elif file_name.get_extension().to_lower() in IMAGE_EXTENSIONS:
				file_array.append(dir.get_current_dir(true)+SEPARATOR+file_name)
			file_name = dir.get_next()


func _set_session_time_label() -> void:
	var formatted_minutes:String = str(new_session_time / 60)
	match formatted_minutes.length():
		1: formatted_minutes = "00" + formatted_minutes
		2: formatted_minutes = "0"  + formatted_minutes
		_: pass
	session_label.text = SESSION_TEXT % formatted_minutes


func _close_window() -> void:
	timeout_audio.stop()
	if stats.audio_enabled:
		page_flip_audio.volume_db = BASE_DB_PAGE_FLIP + stats.audio_addend
		page_flip_audio.play()

	anim_player.speed_scale = FADE_SPEED_OUT
	anim_player.play("fade_out")

	if stats.audio_enabled: await page_flip_audio.finished
	else: await anim_player.animation_finished
	self.queue_free()


func _on_timer_timeout() -> void:
	if is_timer_countdown: _timer_countdown()
	else: _timer_countup()


func _timer_countdown() -> void:
	hours = str(countdown_time / 3600)
	minutes = str(int(countdown_time) % 3600 / 60)
	seconds = str(int(countdown_time) % 3600 % 60)

	if countdown_time > 0: timer_label.text = parent.format_time(TIMER_TEXT,hours,minutes,seconds)

	elif countdown_time == 0 and not stats.break_window_timeout_time == 0:
		message_container.visible = false
		timer_label.remove_theme_color_override("font_shadow_color")
		timer_label.add_theme_constant_override("outline_size", THEME_OUTLINE_SIZE)
		timer_label.self_modulate = SELF_MODULATE
		timer_label.text = timeout_message[randi_range(1,timeout_message.size())]

	elif countdown_time == -(stats.break_window_timeout_time) and stats.break_window_close_on_timeout:
		timer.stop()
		timer_label.visible = false
		_close_window()

	elif countdown_time >= -(stats.break_window_timeout_time) or countdown_time < 0:
		if timer_label.visible: timer_label.visible = false
		else:
			timer_label.visible = true
			if stats.audio_enabled and timeout_audio.volume_db < MAX_DB_TIMEOUT + stats.audio_addend:
				_timer_countdown_audio()

	countdown_time -= 1


func _timer_countdown_audio() -> void:
	if not stats.break_window_close_on_timeout:
		if _is_step_too_large(DB_TIMEOUT_DEFAULT_STEP): timeout_audio.volume_db = MAX_DB_TIMEOUT + stats.audio_addend
		else: timeout_audio.volume_db += DB_TIMEOUT_DEFAULT_STEP

	else:
		var diff:int = abs(MIN_DB_TIMEOUT) + MAX_DB_TIMEOUT
		var step:float = float(diff) / (ceilf(float(stats.break_window_timeout_time) / 2.0) - 1.0)
		if _is_step_too_large(step): timeout_audio.volume_db = MAX_DB_TIMEOUT + stats.audio_addend
		else: timeout_audio.volume_db += step

	timeout_audio.play()


func _is_step_too_large(step) -> bool:
	if timeout_audio.volume_db + step > MAX_DB_TIMEOUT + stats.audio_addend: return true
	else: return false


func _timer_countup() -> void:
	seconds = str(int(seconds) + 1)
	if int(seconds) >= 60: seconds = "0"; minutes = str(int(minutes) + 1)
	if int(minutes) >= 60: minutes = "0"; hours = str(int(hours) + 1)
	timer_label.text = parent.format_time(TIMER_TEXT,hours,minutes,seconds)
